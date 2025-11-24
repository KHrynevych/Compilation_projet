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

(* ---------- Typage des expressions ---------- *)

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
  | Dot (ex, fid) -> ...

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


