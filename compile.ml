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

let field_offset_by_name (env : cenv) (fname : string) : int =
  let res =
    Env.fold (fun _sname sinfo acc ->
              match acc with
              | Some _ -> acc
              | None ->
                  match List.assoc_opt fname sinfo.fields with
                  | Some off -> Some off
                  | None -> None)
      env.senv None
  in
  match res with
  | Some off -> off
  | None -> failwith ("unknown field "^fname)

(* pré-passage : collecte des variables locales d'une fonction *)

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
  let rec add_params env l offset =
    match l with
    | [] -> env
    | (id, _)::q -> 
        add_params (Env.add id.id offset env) q (offset + 4)
  in
  (* on inverse la liste des paramètres pour commencer par le dernier (offset 8 (4*2 pour sp et fp)) et remonter *)
  let param_env = add_params Env.empty (List.rev f.params) 8 in

  let venv, next_off = collect_seq f.body (param_env, 0) in
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


let malloc size =
  li a0 size
  @@ li v0 9
  @@ syscall
  @@ move t0 v0


(* Compilation des expressions *)

type data_acc = asm
let empty_data = nop

let zero = "$zero"

let string_data :(string * string) list ref = ref []

let rec tr_expr (env:cenv) (venv:venv) (e:expr) : asm =
  match e.edesc with
  | Int n -> li t0 (Int64.to_int n)

  | Bool b ->
      let v = if b then 1 else 0 in
      li t0 v

  | String s ->
    let lbl = new_label () in
    string_data := (lbl, s) :: !string_data;
    la t0 lbl

  | Nil -> li t0 0

  | Var id -> load_var venv id.id

  | Dot (e1, fid) ->
      let off = field_offset_by_name env fid.id in
      tr_expr env venv e1
      @@ lw t0 off t0

  | New sname ->
    let sinfo = lookup_struct env sname in
    malloc sinfo.size

  | Call (fid, args) ->
      if fid.id = "new" then
        (* new(T) *)
        (match args with
         | [ { edesc = Var id; _ } ] ->
             (* id doit être le nom d'une struct connue *)
             let sinfo = lookup_struct env id.id in
             malloc sinfo.size
         | _ -> failwith "new expects a single struct name")
      else
        (* appel de fonction normale *)
        let label =
          match Env.find_opt fid.id env.fenv with
          | Some l -> l
          | None -> failwith ("unknown function "^fid.id)
        in
        let code_args =
          List.fold_left
            (fun code arg ->
               code @@ tr_expr env venv arg @@ push t0)
            nop args
        in
        code_args
        @@ jal label
        @@ addi sp sp (4 * List.length args)


  | Print el ->
      (* imprimer tous les arguments comme des entiers pour le moment *)
      let rec print_list = function
        | [] -> nop
        | e1 :: q ->
          tr_expr env venv e1
          @@ move a0 t0
          @@ (match e1.edesc with
              | Int _| Var _ | Bool _ | Binop _ | Unop _| Call _-> 
                li v0 1 @@ syscall
              | String _ -> li v0 4 @@ syscall
              | _ -> failwith "Impossible de print ce type..."
              )
          @@ print_list q
      in
      print_list el
      @@ li t0 0

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
      (* cas special pour l'affectation multiple via un appel de fonction *)
      (* ex: var x, y = f() *)
      (match inits with
       | [ { edesc = Call (_, _); _ } ] when List.length ids > 1 ->
           tr_expr env venv (List.hd inits)
           @@ push t0
           @@ (
             let rec unpack i = function
               | [] -> nop
               | id :: q ->
                   lw t1 0(sp)
                   @@ lw t0 (i*4) t1
                   @@ store_var venv id.id
                   @@ unpack (i+1) q
             in
             unpack 0 ids
           )
           @@ addi sp sp 4

       | _ -> 
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
      )
      

  | Set (lhs, rhs) ->
      (* cas special pour l'affectation multiple via un appel de fonction *)
      (* ex: x, y := f() *)
      (
        match lhs, rhs with
        | vars, [ { edesc = Call (_, _); _ } ] when List.length vars > 1 ->
           tr_expr env venv (List.hd rhs)
           @@ push t0
           @@ (
             let rec unpack i = function
               | [] -> nop
               | var_expr :: q ->
                   (match var_expr.edesc with
                    | Var id ->
                        lw t1 0(sp)
                        @@ lw t0 (i*4) t1
                        @@ store_var venv id.id
                    | _ -> failwith "Only variables allowed in multiple assignment")
                   @@ unpack (i+1) q
             in
             unpack 0 vars
           )
           @@ addi sp sp 4

        | _ -> 
          let rec aux lhs rhs =
            match lhs, rhs with
            | [], [] -> nop
            | el :: ql, er :: qr ->
              tr_expr env venv er
              @@ (match el.edesc with
              | Var id -> store_var venv id.id
              | Dot (e1, fid) ->
                (* on veut que : base = e1 et écrire la valeur (déjà dans $t0) à l'offset du champ *)
                let off = field_offset_by_name env fid.id in
                push t0
                @@ tr_expr env venv e1
                @@ move t1 t0
                @@ pop t0
                @@ sw t0 off t1
              | _ -> failwith "unsupported lvalue in Set (only variables/fields for now)")
              @@ aux ql qr
              | [], _ :: _
              | _ :: _, [] -> failwith "arity mismatch in Set"
            in
            aux lhs rhs
        )

  | If (c, s1, s2) ->
      let else_label = new_label ()
      and end_label = new_label () in
      tr_expr env venv c
      @@ beqz t0 else_label
      @@ tr_seq env venv s1
      @@ b end_label
      @@ label else_label
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
      (match e.edesc with
       | Var id ->
           (* x++ *)
           load_var venv id.id
           @@ addi t0 t0 1
           @@ store_var venv id.id
       | Dot (e1, fid) ->
           (* r.quo++ *)
           let off = field_offset_by_name env fid.id in
           tr_expr env venv e1
           @@ move t1 t0
           @@ lw t0 off t0
           @@ addi t0 t0 1
           @@ sw t0 off t1
       | _ -> failwith "++ must target a variable or a field")
      

  | Dec e -> 
       (match e.edesc with
       | Var id ->
           (* x-- *)
           load_var venv id.id
           @@ addi t0 t0 (-1)
           @@ store_var venv id.id
       | Dot (e1, fid) ->
           (* r.quo-- *)
           let off = field_offset_by_name env fid.id in
           tr_expr env venv e1
           @@ move t1 t0
           @@ lw t0 off t0
           @@ addi t0 t0 (-1)
           @@ sw t0 off t1
       | _ ->
           failwith "-- must target a variable or a field")

  | Return e ->
      let n = List.length e in
      if n = 0 then
        move sp fp @@ pop fp @@ pop ra @@ jr ra
      else if n = 1 then
        tr_expr env venv (List.hd e)
        @@ move sp fp @@ pop fp @@ pop ra @@ jr ra
      else
        (* return multiple : allocation d'un n-uplet *)
        let size = n * 4 in
        let code_list = 
          List.mapi (fun i e ->
            tr_expr env venv e
            @@ lw t1 0(sp)
            @@ sw t0 (i * 4) t1
          ) e 
        in
        let code_store = List.fold_left (@@) nop code_list in
        malloc size
        @@ push t0
        @@ code_store
        @@ pop t0
        @@ move sp fp
        @@ pop fp
        @@ pop ra
        @@ jr ra

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
  let data = 
    List.fold_left (fun acc (lbl, str) -> 
      acc @@ label lbl @@ asciiz str
    ) nop !string_data
  in
  { text; data }
