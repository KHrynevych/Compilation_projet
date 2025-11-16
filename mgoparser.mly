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
%token EQ NEQ LT LE GT GE
%token AND OR ASSIGN DECL INCR DECR
%token EOF

%start prog
%type <Mgoast.program> prog

%left PLUS MINUS
%left STAR SLASH PERCENT

%%

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
 TYPE id=ident STRUCT BEGIN fl=loption(fields) END SEMI
  { Struct { sname = id; fields = List.flatten fl; } }
;

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

varstyp:
  |  x=ident t=mgotype               {[(x,t)]}

fields:
| xt=varstyp SEMI?              { [xt]      }
| xt=varstyp SEMI xtl = fields  { xt :: xtl }

expr:
| e = expr_desc {  { eloc = $startpos, $endpos; edesc = e } }
;

expr_desc:
| n=INT { Int(n) }
;
