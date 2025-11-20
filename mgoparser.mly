%{

  open Lexing
  open Mgoast

  exception Error

%}

%token <int64> INT
%token <string> IDENT
%token <string> STRING
%token PACKAGE IMPORT TYPE STRUCT FUNC RETURN IF ELSE FOR VAR TRUE FALSE NIL

%token LPAR RPAR BEGIN END COMMA SEMI DOT
%token PLUS MINUS STAR SLASH PERCENT
%token EQ NEQ LT LE GT GE NOT
%token AND OR ASSIGN DECL INCR DECR
%token POINT
%token PPLUS MMINUS
%token EOF

%start prog
%type <Mgoast.program> prog

%left PLUS MINUS
%left STAR SLASH PERCENT

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
                    | _        -> TStruct s
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
| ins_sim=instr_simple { { iloc= $startpos, $endpos; idesc = ins_sim } }
;

instr_simple:
| ex=expr         {Expr(ex)}
| ex=expr PPLUS   {Inc(ex)}
| ex=expr MMINUS  {Dec(ex)}
| ex1=expr_list ASSIGN ex2=expr_list          {Set( (ex1, ex2) )}
| id_list=ident_list DECL ex_list=expr_list   
{ Vars( (id_list, None, List.map (fun ex -> {iloc= $startpos, $endpos; idesc=Expr(ex)}) ex_list ))}
(* pas sûr pour l'option de déclaration, il faut peut être ajouter le type
 d'une façon ou d'une autre voir faire complêtement autrement? *)
;


expr:
| e = expr_desc {  { eloc = $startpos, $endpos; edesc = e } }
;

expr_desc:
| n=INT { Int(n) }
| fmt=IDENT POINT print=IDENT LPAR ex_li=expr_list RPAR
  {if fmt="fmt" && print="Print" then Print(ex_li) else raise Error}
;

(* liste d'expressions non nulle séparées par des virgules *)
expr_list:
| e=expr {[e]}
| e=expr COMMA e1=expr_list {e::e1}
;