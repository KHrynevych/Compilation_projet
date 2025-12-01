open Mgoast

exception Error of Mgoast.location * string
let error loc s = raise (Error (loc,s))

let type_error loc ty_actual ty_expected =
  error loc (Printf.sprintf "expected %s, got %s"
           (typ_to_string ty_expected) (typ_to_string ty_actual))

module Env = Map.Make(String)

(* 3 environnements pour stocker
     les variables avec leur type,
     les fonctions avec leur signature
     les structures avec leurs champs
*)
    
type tenv = typ Env.t
type fenv = (typ list) * (typ list) Env.t
type senv = (ident * typ) list
type fdef = func_def

let dloc : location = (Lexing.dummy_pos, Lexing.dummy_pos)

let dummy = "_"

let add_env l tenv =
  List.fold_left (fun env (x, t) -> if x.id = dummy then env else Env.add x.id   t env) tenv l

let equal_typ (a : typ) (b : typ) : bool =
  match a, b with
  | TInt, TInt | TBool, TBool | TString, TString -> true
  | TStruct sa, TStruct sb -> sa = sb
  | _ -> false

(* Vérifs de base sur les types / champs *)

let check_typ (senv : senv) (t : typ) : unit =
  match t with
  | TInt | TBool | TString -> ()
  | TStruct s ->
      if not (Env.mem s senv) then
        error dloc (Printf.sprintf "unknown struct %s" s)

let check_fields (senv : senv) (lf : (ident * typ) list) : unit =
  let seen = Hashtbl.create 16 in
  List.iter
    (fun (id, t) ->
       if Hashtbl.mem seen id.id then
         error id.loc (Printf.sprintf "duplicate field %s" id.id);
       Hashtbl.add seen id.id ();
       check_typ senv t)
    lf

let lookup_field (fields : (ident * typ) list) (fname : string) : (typ * location) =
  let rec aux = function
    | [] -> raise Not_found
    | (id, t) :: q -> if id.id = fname then (t, id.loc) else aux q
  in
  aux fields

(* Typage des expressions *)

let rec check_expr ~(fmt_imported:bool) (senv:senv) (fenv:fenv) (tenv:tenv) (e:expr) (expected:typ) : unit =
  match e.edesc with
  | Nil ->
      (match expected with
       | TStruct _ -> ()
       | _ -> error e.eloc "nil can only be used for struct/pointer types")
  | _ ->
      let te = type_expr ~fmt_imported senv fenv tenv e in
      if not (equal_typ te expected) then type_error e.eloc te expected

and type_expr ~(fmt_imported:bool) (senv:senv) (fenv:fenv) (tenv:tenv) (e:expr) : typ =
  match e.edesc with
  | Int _    -> TInt
  | Bool _   -> TBool
  | String _ -> TString
  | Nil      -> error e.eloc "untyped nil requires a target type"
  | New s ->
      if not (Env.mem s senv) then error e.eloc (Printf.sprintf "unknown struct %s" s);
      TStruct s
  | Var id ->
      (match Env.find_opt id.id tenv with
       | Some t -> t
       | None -> error id.loc (Printf.sprintf "undefined variable %s" id.id))
  | Dot (ex, fid) -> 
      (match type_expr ~fmt_imported senv fenv tenv ex with
        | TStruct s ->
            let fields =
              match Env.find_opt s senv with
              | Some fs -> fs
              | None -> error ex.eloc (Printf.sprintf "unkown struct %s" s)
            in
            (match lookup_field fields fid.id with
            | t, _ -> t
            | exception Not_found -> error fid.loc (Printf.sprintf "unkown field %s in %s" fid.id s))
        | t -> error ex.eloc (Printf.sprintf "field selection on non-struct (%s)" (typ_to_string t)))
  | Call (fid, args) ->
      (match Env.find_opt fid.id fenv with
       | None -> error fid.loc (Printf.sprintf "undefined function %s" fid.id)
       | Some (ptys, rtys, _def) ->
           let nargs = List.length args and nparams = List.length ptys in
           if nargs <> nparams then
             error e.eloc (Printf.sprintf "function %s expects %d arg(s), got %d"
                              fid.id nparams nargs);
           List.iter2 (fun a t -> check_expr ~fmt_imported senv fenv tenv a t) args ptys;
           (match rtys with
            | [t] -> t
            | []  -> error e.eloc "function returns no value"
            | _   -> error e.eloc "multiple-value used in single-value context"))
  | Print args ->
      if not fmt_imported then error e.eloc "fmt not imported: Print is unavailable";
      List.iter (fun a -> ignore (type_expr ~fmt_imported senv fenv tenv a)) args;
      TInt
  | Unop (Not, e1) ->
      check_expr ~fmt_imported senv fenv tenv e1 TBool; TBool
  | Unop (Opp, e1) ->
      check_expr ~fmt_imported senv fenv tenv e1 TInt; TInt
  | Binop (Add, a, b)
  | Binop (Sub, a, b)
  | Binop (Mul, a, b)
  | Binop (Div, a, b)
  | Binop (Rem, a, b) ->
      check_expr ~fmt_imported senv fenv tenv a TInt;
      check_expr ~fmt_imported senv fenv tenv b TInt; TInt
  | Binop (Lt, a, b) | Binop (Le, a, b)
  | Binop (Gt, a, b) | Binop (Ge, a, b) ->
      check_expr ~fmt_imported senv fenv tenv a TInt;
      check_expr ~fmt_imported senv fenv tenv b TInt; TBool
  | Binop (Eq, a, b) | Binop (Neq, a, b) ->
      let ta = type_expr ~fmt_imported senv fenv tenv a in
      let tb = type_expr ~fmt_imported senv fenv tenv b in
      if not (equal_typ ta tb) then type_error e.eloc ta tb;
      TBool
  | Binop (And, a, b) | Binop (Or, a, b) ->
      check_expr ~fmt_imported senv fenv tenv a TBool;
      check_expr ~fmt_imported senv fenv tenv b TBool; TBool

let is_lvalue (e : expr) : bool =
  match e.edesc with
  | Var _ | Dot _ -> true
  | _ -> false

(* Typage des instructions *)

let rec check_instr ~(fmt_imported:bool) (senv:senv) (fenv:fenv) (ret:typ list) (tenv:tenv) (i:instr) : tenv =
  match i.idesc with
  | Expr e ->
      ignore (type_expr ~fmt_imported senv fenv tenv e); tenv
  | Block bl ->
      ignore (check_seq ~fmt_imported senv fenv ret tenv bl); tenv
  | If (cond, thn, els) ->
      check_expr ~fmt_imported senv fenv tenv cond TBool;
      ignore (check_seq ~fmt_imported senv fenv ret tenv thn);
      ignore (check_seq ~fmt_imported senv fenv ret tenv els);
      tenv
  | For (cond, body) ->
      check_expr ~fmt_imported senv fenv tenv cond TBool;
      ignore (check_seq ~fmt_imported senv fenv ret tenv body); tenv
  | Inc e ->
      check_expr ~fmt_imported senv fenv tenv e TInt;
      if not (is_lvalue e) then error i.iloc "++ must target a variable/field";
      tenv
  | Dec e ->
      check_expr ~fmt_imported senv fenv tenv e TInt;
      if not (is_lvalue e) then error i.iloc "-- must target a variable/field";
      tenv
  | Set (lvals, rvals) ->
      let tl = List.map (fun e -> if not (is_lvalue e) then error i.iloc "assignment target is not assignable";
                                   type_expr ~fmt_imported senv fenv tenv e) lvals in
      let tr = List.map (fun e -> type_expr ~fmt_imported senv fenv tenv e) rvals in
      if List.length tl <> List.length tr then
        error i.iloc "assignment arity mismatch";
      List.iter2
        (fun ta tb -> if not (equal_typ ta tb) then type_error i.iloc tb ta)
        tl tr;
      tenv
  | Vars (ids, t_opt, init_seq) ->
      (* on attend à des initialisations sous forme d’instructions Expr e *)
      let inits =
        List.map
          (function
            | { idesc = Expr e; _ } -> e
            | _ -> error i.iloc "initializers must be expressions")
          init_seq
      in
      (match t_opt, inits with
       | None, [] ->
           (* var x, y; → déclarées mais non initialisées : on peut refuser l’usage ultérieur avant assignation
              Ici on les interdit sans type : on lève une erreur explicite. *)
           error i.iloc "untyped variables require initial values"
       | None, _ ->
           if List.length ids <> List.length inits then
             error i.iloc "declaration arity mismatch";
           let inferred =
             List.map (fun e -> type_expr ~fmt_imported senv fenv tenv e) inits
           in
           let tenv' =
             List.fold_left2
               (fun acc id t -> if id.id = dummy then acc else Env.add id.id t acc)
               tenv ids inferred
           in
           tenv'
       | Some t, _ ->
           (* vérifier types des initialisations si présentes *)
           List.iter (fun e -> check_expr ~fmt_imported senv fenv tenv e t) inits;
           let tenv' =
             List.fold_left
               (fun acc id -> if id.id = dummy then acc else Env.add id.id t acc)
               tenv ids
           in
           tenv')
  | Return exs ->
      if List.length ret <> List.length exs then
        error i.iloc "return arity mismatch";
      List.iter2 (fun t e -> check_expr ~fmt_imported senv fenv tenv e t) ret exs;
      tenv

and check_seq ~(fmt_imported:bool) (senv:senv) (fenv:fenv) (ret:typ list) (tenv:tenv) (s:seq) : tenv =
  List.fold_left (check_instr ~fmt_imported senv fenv ret) tenv s
        

let prog (fmt,ld) =
  (* collecte les noms des fonctions et des structures sans les vérifier *)
  let (fenv,senv) =
    List.fold_left
      (fun (fenv,senv) d ->
         match d with Struct(s) -> (fenv, Env.add s.sname.id s.fields senv)
                    | Fun(f)   -> failwith "à compléter")
      (Env.empty, Env.empty) ld
  in
  let check_typ t = failwith "case not implemented in check_typ"
  in
  let check_fields lf = failwith "case not implemented in check_fields"
  in
  let rec check_expr e typ tenv =
    if e.edesc = Nil then  failwith "case not implemented in check"
    else let typ_e = type_expr e tenv in
    if typ_e <> typ then type_error e.eloc typ_e typ
  and type_expr e tenv = match e.edesc with
    | Int _  -> TInt
    | _ -> failwith "case not implemented in type_expr"

  in

  let rec check_instr i ret tenv = match i.idesc with
    | _ -> failwith "case not implemented in check_instr"
  and check_seq s ret tenv =
    List.iter (fun i -> check_instr i ret tenv) s
  in
  
  let check_function f = failwith "case not implemented in check_function"

  in Env.iter (fun _ lf -> check_fields lf) senv;
     Env.iter (fun _ fd -> check_function fd) fenv


