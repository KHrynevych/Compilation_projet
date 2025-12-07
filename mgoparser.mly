%{

  open Lexing
  open Mgoast

  exception Error

%}

%token <int64> INT
%token <string> IDENT
%token <string> STRING
%token PACKAGE IMPORT TYPE STRUCT FUNC RETURN IF ELSE FOR VAR TRUE FALSE NIL

%token LPAR RPAR BEGIN END COMMA SEMI
%token PLUS MINUS STAR SLASH PERCENT
%token EQ NEQ LT LE GT GE NOT
%token AND OR ASSIGN DECL
%token POINT
%token PPLUS MMINUS
%token FMTPRINT
%token EOF

%start prog
%type <Mgoast.program> prog

%left OR
%left AND
%left EQ NEQ LT LE GT GE
%left PLUS MINUS
%left STAR SLASH PERCENT
%left POINT
%nonassoc NOT UMINUS


%%

(* Règles *)
prog:
| PACKAGE main=IDENT SEMI decls=list(decl) EOF
    { if main="main" then (false, decls) else raise Error}
| PACKAGE main=IDENT SEMI IMPORT fmt=STRING SEMI decls=list(decl) EOF
    { if main="main" && fmt="fmt" then (true, decls) else raise Error} 
;

ident:
  id = IDENT { { loc = $startpos, $endpos; id = id } }
;

decl:
| TYPE id=ident STRUCT BEGIN fl=loption(fields) END SEMI
  { Struct { sname = id; fields = List.flatten fl; } }
| FUNC id=ident LPAR par=loption(params) RPAR ret=loption(type_retour) bl=bloc SEMI
  { Fun { fname = id; params = List.flatten par; return= ret; body = bl; } }
;

type_retour:
| mtype=mgotype {[mtype]}
| LPAR types=mgotype_list RPAR {types}
;

;
(* mgotype = type
il faut modifier dans le cas où c'est une structure et vérifier qu'il y a bien une étoile au début *)
mgotype:
  | STAR s=IDENT  { TStruct(s) }
  | s=IDENT       {
                    match s with
                    | "int"    -> TInt
                    | "bool"   -> TBool
                    | "string" -> TString
                    | _        -> raise Error
                    }
;

mgotype_list:
| mtype=mgotype COMMA? {[mtype]}
| type1=mgotype COMMA types=mgotype_list {type1::types}
;


(* varstyp + ident_list = vars *)
varstyp:
|  x_list=ident_list t=mgotype   { List.map (fun x -> (x,t)) x_list}
;

ident_list:
| x=ident {[x]}
| x=ident COMMA x1=ident_list {x :: x1}
;

fields:
| xt=varstyp SEMI?              { [xt]      }
| xt=varstyp SEMI xtl = fields  { xt :: xtl }
;

params:
| xt=varstyp COMMA?             { [xt]      }
| xt=varstyp COMMA xtl = params { xt :: xtl }
;

bloc:
BEGIN ins_list=loption(instr_list) END {ins_list}
;

instr_list:
| ins = instr SEMI? {[ins]}
| ins1=instr SEMI ins_list=instr_list {ins1::ins_list}
;

(* il faut compléter les cas pour instr, instr_simple, expr, expr_desc, etc *)
instr:
| i=instr_desc { {iloc= $startpos, $endpos; idesc = i} }
;

instr_desc:
| ins_sim=instr_simple { ins_sim }
| bl=bloc {Block(bl)}
| iif=instr_if {iif}
| VAR idl=ident_list typ=option(mgotype) {Vars(idl, typ, [])}
| VAR idl=ident_list typ=option(mgotype) ASSIGN exl=expr_list 
 {Vars(idl, typ, List.map (fun ex -> {iloc= $startpos, $endpos; idesc = Expr(ex)}) exl)}
| RETURN exl=loption(expr_list) {Return(exl)}
| FOR bl=bloc {For({eloc= $startpos, $endpos; edesc=Bool(true)}, bl)}
| FOR ex=expr bl=bloc {For(ex, bl)}
| FOR is1=instr_simple SEMI ex=expr SEMI is2=instr_simple bl=bloc 
  { Block([
      { iloc = ($startpos, $endpos); idesc = is1 };
      { iloc = ($startpos, $endpos); idesc = For(ex, 
                                                    (let rec aj_fin b i = match b with 
                                                    | [] -> [{iloc = ($startpos, $endpos); idesc = is2 }]
                                                    | l::bb -> l::aj_fin bb i
                                                    in aj_fin bl is2)
      ) }
    ]) }
| FOR SEMI ex=expr SEMI is2=instr_simple bl=bloc 
{ For(ex, (let rec aj_fin b i = match b with 
                                | [] -> [{iloc = ($startpos, $endpos); idesc = is2 }]
                                | l::bb -> l::aj_fin bb i
                                in
                                aj_fin bl is2)) }
| FOR is1=instr_simple SEMI ex=expr SEMI bl=bloc
  { Block([
      { iloc = ($startpos, $endpos); idesc = is1 };
      { iloc = ($startpos, $endpos); idesc = For(ex, bl) }
    ]) }
;

instr_simple:
| ex=expr         {Expr(ex)}
| ex=expr PPLUS   {Inc(ex)}
| ex=expr MMINUS  {Dec(ex)}
| ex1=expr_list ASSIGN ex2=expr_list          {Set( ex1, ex2 )}
| ex1=expr_list DECL ex2=expr_list
{ Vars( List.map (fun ex -> match ex.edesc with
| Var id -> id
| _ -> raise Error) ex1,
        None, 
        List.map (fun ex -> {iloc= $startpos, $endpos; idesc=Expr(ex)}) ex2 )}
;

instr_if:
| IF ex=expr bl=bloc {If(ex, bl, [])}
| IF ex=expr bl=bloc ELSE bl2=bloc     {If(ex, bl, bl2)}
| IF ex=expr bl=bloc ELSE ins=instr_if {If(ex, bl, [{iloc= $startpos, $endpos; idesc=ins}])}
;

expr:
| e = expr_desc {  { eloc = $startpos, $endpos; edesc = e } }
| LPAR e = expr RPAR { e }
;

expr_desc:
| n=INT { Int(n) }
| ch=STRING { String(ch) }
| TRUE {Bool(true)}
| FALSE {Bool(false)}
| NIL {Nil}
| id=ident {Var(id)}
| ex=expr POINT id=ident {Dot(ex, id)}
| id=ident LPAR exl=loption(expr_list) RPAR {Call(id, exl)}
| FMTPRINT LPAR ex_li=expr_list RPAR {Print(ex_li)}
| NOT ex=expr {Unop(Not, ex)}
| MINUS ex=expr %prec UMINUS {Unop(Opp, ex)}

| ex1=expr PLUS ex2=expr {Binop(Add, ex1, ex2)}
| ex1=expr MINUS ex2=expr {Binop(Sub, ex1, ex2)}
| ex1=expr STAR ex2=expr {Binop(Mul, ex1, ex2)}
| ex1=expr SLASH ex2=expr {Binop(Div, ex1, ex2)}
| ex1=expr PERCENT ex2=expr {Binop(Rem, ex1, ex2)}
| ex1=expr LT ex2=expr {Binop(Lt, ex1, ex2)}
| ex1=expr LE ex2=expr {Binop(Le, ex1, ex2)}
| ex1=expr GT ex2=expr {Binop(Gt, ex1, ex2)}
| ex1=expr GE ex2=expr {Binop(Ge, ex1, ex2)}
| ex1=expr EQ ex2=expr {Binop(Eq, ex1, ex2)}
| ex1=expr NEQ ex2=expr {Binop(Neq, ex1, ex2)}
| ex1=expr AND ex2=expr {Binop(And, ex1, ex2)}
| ex1=expr OR ex2=expr {Binop(Or, ex1, ex2)}
;

(* liste d'expressions non nulle séparées par des virgules *)
expr_list:
| e=expr {[e]}
| e=expr COMMA e1=expr_list {e::e1}
;