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
let fp = "$fp"

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

(* Pré-passage : collecte des variables locales d'une fonction *)

let rec collect_seq (s:seq) ((venv, next_off) : venv * int) : venv * int =
  List.fold_left
    (fun (env, off) i ->
       match i.idesc with
       | Vars (ids, _topt, body) ->
           (* chaque identifiant reçoit un offset négatif supplémentaire *)
           let env', off' =
             List.fold_left
               (fun (e, o) id ->
                  let o' = o - word_size in
                  (Env.add id.id o' e, o'))
               (env, off) ids
           in
           collect_seq body (env', off')

       | Block s' -> collect_seq s' (env, off)

       | If (_, s1, s2) ->
           let env1, off1 = collect_seq s1 (env, off) in
           collect_seq s2 (env1, off1)

       | For (_, s') -> collect_seq s' (env, off)

       | _ -> (env, off))
    (venv, next_off) s

let build_venv (f:func_def) : venv * int =
  (* on part de next_off = 0, on descend de -4 en -4 *)
  let venv, next_off = collect_seq f.body (Env.empty, 0) in
  let locals_size = -next_off in  (* locals_size >= 0 *)
  (venv, locals_size)

let load_var (venv:venv) (name:string) : asm =
  match Env.find_opt name venv with
  | Some off -> lw t0 off fp
  | None -> failwith ("unknown variable "^name)

let store_var (venv:venv) (name:string) : asm =
  match Env.find_opt name venv with
  | Some off -> sw t0 off fp
  | None -> failwith ("unknown variable "^name)


(* Compilation des expressions *)

type data_acc = asm

let empty_data = nop

let add_string (data:data_acc) (lbl:string) (s:string) : data_acc =
  data @@ Mips.label lbl @@ asciiz s

let zero = "$zero"

let rec tr_expr (env:cenv) (venv:venv) (e:expr) : asm =
  match e.edesc with
  | Int n -> li t0 (Int64.to_int n)

  | Bool b ->
      let v = if b then 1 else 0 in
      li t0 v

  | String s -> failwith "A compléter: String"

  | Nil -> li t0 0

  | Var id -> load_var venv id.id

  | Dot (e1, fid) -> failwith "A compléter: Dot"

  | New sname -> failwith "A compléter: New"

  | Call (fid, args) -> 
    let label = Env.find fid.id env.fenv in 
    let code_args = List.fold_left (fun code arg ->
        code @@ tr_expr env venv arg @@ push t0
    ) nop args in

    code_args
    @@ jal label                           (* saut vers la fonction et sauvegarde adresse retour *)
    @@ addi sp sp (4 * List.length args)   (* nettoyage de la pile (arguments) *)


  | Print el ->
      (* imprimer tous les arguments comme des entiers pour le moment *)
      let rec print_list = function
        | [] -> nop
        | e1 :: q ->
            tr_expr env venv e1
            @@ move a0 t0
            @@ li v0 1 @@ syscall
            @@ print_list q
      in
      print_list el
      @@ li t0 0  (* valeur de retour de Print : 0 pour le moment *)

  | Unop (op, e1) ->
      begin match op with
      | Opp ->
          (* $t0 := - (valeur de e1)  ->  sub $t0, $zero, $t0 *)
          tr_expr env venv e1
          @@ sub t0 zero t0
      | Not ->
          let l_true = new_label () in
          let l_end  = new_label () in
          tr_expr env venv e1
          @@ beqz t0 l_true
          @@ li t0 0
          @@ b l_end
          @@ label l_true
          @@ li t0 1
          @@ label l_end
      end

  | Binop (bop, e1, e2) ->
      let op =
        match bop with
        | Add -> add
        | Mul -> mul
        | Lt  -> slt
        | And -> and_
        | Sub -> sub
        | Div -> div
        | Rem -> rem
        | Le  -> sle
        | Gt  -> sgt
        | Ge  -> sge
        | Eq  -> seq
        | Neq -> sne
        | Or  -> or_
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
  | Expr e -> tr_expr env venv e

  | Vars (ids, _topt, body) ->
      let rec extract_inits acc = function
        | [] -> List.rev acc
        | { idesc = Expr e; _ } :: q -> extract_inits (e :: acc) q
        | _ :: _ -> failwith "unexpected non-expression initializer in Vars"
      in
      let inits = extract_inits [] body in
      let rec init ids inits =
        match ids, inits with
        | [], [] -> nop
        | id :: ids', e :: es ->
            tr_expr env venv e
            @@ store_var venv id.id
            @@ init ids' es
        | id :: ids', [] ->
            (* 0 par défaut *)
            li t0 0
            @@ store_var venv id.id
            @@ init ids' []
        | [], _ :: _ -> failwith "too many initializers in Vars"
      in
      init ids inits

  | Set (lhs, rhs) ->
      let rec aux lhs rhs =
        match lhs, rhs with
        | [], [] -> nop
        | el :: ql, er :: qr ->
            tr_expr env venv er
            @@ (match el.edesc with
                | Var id -> store_var venv id.id
                | _ -> failwith "unsupported lvalue in Set (only variables for now)")
            @@ aux ql qr
        | [], _ :: _
        | _ :: _, [] -> failwith "arity mismatch in Set"
      in
      aux lhs rhs

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

  | Inc e -> 
      tr_expr env venv e
      @@ addi t0 t0 1
      

  | Dec e -> 
      tr_expr env venv e
      @@ addi t0 t0 (-1)

  | Return [] -> 
      move sp fp
      @@ pop fp
      @@ pop ra
      @@ jr ra               (* retour à l'appelant *)

  | Return [e] ->
      tr_expr env venv e
      @@ move sp fp
      @@ pop fp
      @@ pop ra
      @@ jr ra               (* retour à l'appelant *)

  | Return _ -> failwith "A compléter: Return avec plusieurs valeurs"

(* compilation d'une fonction, puis d'une liste de déclarations *)

let tr_fun (env:cenv) (f:func_def) : asm =
  let lbl = Env.find f.fname.id env.fenv in
  let venv, locals_size = build_venv f in
  label lbl
  @@ push ra                     (* sauvegarde de l'adresse de retour *)
  @@ push fp                     (* sauvegarde de l'ancien frame pointer *)
  @@ move fp sp                  (* le fp pointe vers la nouvelle base de pile *)
  (* allocation des variables locales *)
  @@ (if locals_size > 0
      then addi sp sp (-locals_size)
      else nop)
  @@ tr_seq env venv f.body
  (* après l'appel à la fonction; utilisé seulement quand il n'y a pas de return *)
  @@ move sp fp
  @@ pop fp
  @@ pop ra
  @@ jr ra               (* retour à l'appelant *)

let rec tr_ldecl (env:cenv) (p:decl list) : asm =
  match p with
  | [] -> nop
  | Fun df :: q -> tr_fun env df @@ tr_ldecl env q
  | Struct _ :: q -> tr_ldecl env q

let tr_prog (p:decl list) : program =
  let senv = build_struct_env p in
  let fenv = build_func_env p in
  let env  = { senv; fenv } in
  let text = 
    jal "main"
    @@ li v0 10
    @@ syscall
    @@ tr_ldecl env p in
  let data = nop (* pour le moment pas de données statiques *) in
  { text; data }
