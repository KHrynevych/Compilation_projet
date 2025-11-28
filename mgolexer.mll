{

  open Lexing
  open Mgoparser

  exception Error of string

  let keyword_or_ident =
    let h = Hashtbl.create 24 in
    List.iter (fun (s, k) -> Hashtbl.add h s k)
      [ "package",    PACKAGE; "import",     IMPORT;
        "type",       TYPE;    "struct",     STRUCT;    
        "else",       ELSE;    "false",      FALSE;
        "for",        FOR;     "func",       FUNC;
        "if",         IF;      "nil",        NIL;
        "return",     RETURN;  "true",       TRUE;
        "var",        VAR;
      ] ;
    fun s -> match Hashtbl.find_opt h s with Some k -> k
                                            | None -> IDENT s
    let max_i64 = Int64.max_int

    let int64_of_lexeme s =
      try
        let n = Int64.of_string s in
        if n < Int64.zero || n > max_i64 then raise Exit; n
      with _ -> raise (Error "invalid or out-of-range integer literal")      
}

let digit = ['0'-'9']
let hexd = ['0'-'9' 'a'-'f' 'A'-'F']
let decint = digit+
let hexint = ('0''x'| '0''X') hexd+
let intlit = hexint | decint
let alpha = ['a'-'z' 'A'-'Z' '_']
let ident = alpha (alpha | digit)*

  
rule token = parse
  | [' ' '\t' '\r' '\n']+

  | "//" [^ '\n']*  { token lexbuf }
  | "/*"            { comment lexbuf; token lexbuf }

  | intlit as n  { INT(int64_of_lexeme n) }
  | ident as id  { keyword_or_ident id }
  | '"'          { string_lit (Buffer.create 16) lexbuf }

  | ";"  { SEMI } | "("  { LPAR } | ")"  { RPAR }
  | "{"  { BEGIN } | "}"  { END } | "*"  { STAR }
  | "."  { POINT } | ","  { COMMA }

  | "==" { EQ } | "!=" { NEQ } | "<=" { LE } | ">=" { GE }
  | "<"  { LT } | ">"  { GT } | "&&" { AND } | "||" { OR }
  | "+"  { PLUS } | "-"  { MINUS } | "/"  { SLASH }
  | "++" { PPLUS } | "--" { MMINUS }
  | "!"  { NOT }  | ":=" { DECL } | "="  { ASSIGN }
  | "%"  { PERCENT } | "fmt.Print" {FMTPRINT}

  | _    { raise (Error ("unknown character : " ^ lexeme lexbuf)) }
  | eof  { EOF }

and comment = parse
  | '\n' { new_line lexbuf; comment lexbuf }
  | "*/" { () }
  | _    { comment lexbuf }
  | eof  { raise (Error "unterminated comment") }
and string_lit buf = parse
  | '"'         { STRING (Buffer.contents buf) }
  | "\\\\"      { Buffer.add_char buf '\\'; string_lit buf lexbuf }
  | "\\\""      { Buffer.add_char buf '"';  string_lit buf lexbuf }
  | "\\n"       { Buffer.add_char buf '\n'; string_lit buf lexbuf }
  | "\\t"       { Buffer.add_char buf '\t'; string_lit buf lexbuf }
  | (['\032'-'\126'] # ['\\' '\"']) as c { Buffer.add_char buf c;    string_lit buf lexbuf }
  | eof         { raise (Error "unterminated string literal") }
  | _           { raise (Error "illegal character in string") }
