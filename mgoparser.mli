
(* The type of tokens. *)

type token = 
  | VAR
  | TYPE
  | TRUE
  | STRUCT
  | STRING of (string)
  | STAR
  | SLASH
  | SEMI
  | RPAR
  | RETURN
  | PLUS
  | PERCENT
  | PACKAGE
  | OR
  | NIL
  | NEQ
  | MINUS
  | LT
  | LPAR
  | LE
  | INT of (int64)
  | INCR
  | IMPORT
  | IF
  | IDENT of (string)
  | GT
  | GE
  | FUNC
  | FOR
  | FALSE
  | EQ
  | EOF
  | END
  | ELSE
  | DOT
  | DECR
  | DECL
  | COMMA
  | BEGIN
  | ASSIGN
  | AND

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val prog: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Mgoast.program)
