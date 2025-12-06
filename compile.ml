open Mgoast
open Mips

module Env = Map.Make(String)

(* Informations sur une structure *)
type struct_info = {
  size   : int;
  fields : (string * int) list;  (* champ -> offset *)
}

(* Environnement global de compilation *)
type cenv = {
  senv : struct_info Env.t;      (* nom_struct -> infos *)
  fenv : string Env.t;           (* nom_fonction -> label MIPS *)
}

(* Environnement local : variables -> offset par rapport à $sp *)
type venv = int Env.t

let word_size = 4

let new_label =
  let cpt = ref (-1) in
  fun () -> incr cpt; Printf.sprintf "_label_%i" !cpt

(* Construction des environnements globaux *)

let build_struct_env (decls : decl list) : struct_info Env.t =
  let add_struct env = function
    | Struct s ->
        let offset = ref 0 in
        let fields =
          List.map
            (fun (id, _t) ->
               let off = !offset in
               offset := !offset + word_size;   (* 4 octets par champ *)
               (id.id, off))
            s.fields
        in
        Env.add s.sname.id { size = !offset; fields } env
    | Fun _ -> env
  in
  List.fold_left add_struct Env.empty decls

let build_func_env (decls : decl list) : string Env.t =
  let add_fun env = function
    | Fun f ->
        let lbl = f.fname.id in
        Env.add f.fname.id lbl env
    | Struct _ -> env
  in
  List.fold_left add_fun Env.empty decls

let lookup_struct (env:cenv) name =
  match Env.find_opt name env.senv with
  | Some si -> si
  | None -> failwith ("unknown struct in compile: "^name)

let field_offset (env:cenv) sname fname =
  let si = lookup_struct env sname in
  match List.assoc_opt fname si.fields with
  | Some off -> off
  | None -> failwith ("unknown field "^fname^" in struct "^sname)

(* Compilation des expressions *)

type data_acc = asm

let empty_data = nop

let add_string (data:data_acc) (lbl:string) (s:string) : data_acc =
  data @@ Mips.label lbl @@ asciiz s

let rec tr_expr (env:cenv) (venv:venv) (e:expr) : asm =
  match e.edesc with
  | Int n -> li t0 (Int64.to_int n)

  | Bool b ->
      let v = if b then 1 else 0 in
      li t0 v

  | String s -> failwith "A compléter: String"

  | Nil -> li t0 0

  | Var id -> failwith "A compléter: Var"

  | Dot (e1, fid) -> failwith "A compléter: Dot"

  | New sname -> failwith "A compléter: New"

  | Call (fid, args) -> failwith "A compléter: Call"

  | Print el -> failwith "A compléter: Print"

  | Unop (op, e1) -> failwith "A compléter: Unop"

  | Binop (bop, e1, e2) ->
      let op =
        match bop with
        | Add -> add
        | Mul -> mul
        | Lt  -> slt
        | And -> and_
        | Sub | Div | Rem
        | Le  | Gt | Ge | Eq | Neq | Or ->
            failwith "A compléter: autres opérateurs binaires"
      in
      tr_expr env venv e2
      @@ push t0
      @@ tr_expr env venv e1
      @@ pop t1
      @@ op t0 t0 t1

(* Compilation des instructions *)

and tr_seq (env:cenv) (venv:venv) (s:seq) : asm =
  match s with
  | []   -> nop
  | [i]  -> tr_instr env venv i
  | i::q -> tr_instr env venv i @@ tr_seq env venv q

and tr_instr (env:cenv) (venv:venv) (i:instr) : asm =
  match i.idesc with
  | Expr e ->
      tr_expr env venv e

  | Vars (ids, _topt, body) -> failwith "A compléter: Vars"

  | Set (lhs, rhs) -> failwith "A compléter: Set"

  | If (c, s1, s2) ->
      let then_label = new_label ()
      and end_label = new_label () in
      tr_expr env venv c
      @@ beqz t0 end_label
      @@ tr_seq env venv s1
      @@ b end_label
      @@ label then_label
      @@ tr_seq env venv s2
      @@ label end_label

  | For (c, s) ->
      let test_label = new_label ()
      and code_label = new_label () in
      b test_label
      @@ label code_label
      @@ tr_seq env venv s
      @@ label test_label
      @@ tr_expr env venv c
      @@ bnez t0 code_label

  | Block s -> tr_seq env venv s

  | Inc e -> failwith "A compléter: Inc"

  | Dec e -> failwith "A compléter: Dec"

  | Return [] ->
      li v0 10 @@ syscall

  | Return [e] ->
      tr_expr env venv e
      @@ move a0 t0
      @@ li v0 1 @@ syscall
      @@ li v0 10 @@ syscall

  | Return _ ->
      failwith "A compléter: Return avec plusieurs valeurs"

(* Compilation d'une fonction, puis d'une liste de déclarations *)

let tr_fun (env:cenv) (f:func_def) : asm =
  let lbl = Env.find f.fname.id env.fenv in
  let venv = Env.empty in
  label lbl
  @@ tr_seq env venv f.body

let rec tr_ldecl (env:cenv) (p:decl list) : asm =
  match p with
  | [] -> nop
  | Fun df :: q ->
      tr_fun env df @@ tr_ldecl env q
  | Struct _ :: q ->
      tr_ldecl env q

let tr_prog (p:decl list) : program =
  let senv = build_struct_env p in
  let fenv = build_func_env p in
  let env  = { senv; fenv } in
  let text = tr_ldecl env p in
  let data = nop (* pour l’instant, pas de données statiques *) in
  { text; data }
