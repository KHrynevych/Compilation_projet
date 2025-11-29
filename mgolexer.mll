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

  let insert_semi = ref false

  (* sop = semi_ou_pas (nom raccourci pour rendre le code moins moche...) *)
  (* il y a peut etre des endroits où l'analyseur rajoute des semi alors qu'il devrait juste renvoyer un erreur :( *)
  let sop t =
    insert_semi := (match t with
      | IDENT _ | INT _ | STRING _
      | TRUE | FALSE | NIL | RETURN
      | PPLUS | MMINUS | RPAR | END -> true
      | _ -> false);
    t
}

let digit = ['0'-'9']
let hexd = ['0'-'9' 'a'-'f' 'A'-'F']
let decint = digit+
let hexint = ('0''x'| '0''X') hexd+
let intlit = hexint | decint
let alpha = ['a'-'z' 'A'-'Z' '_']
let ident = alpha (alpha | digit)*

  
rule token = parse
  | [' ' '\t']+     { token lexbuf }
  
  | '\n' | '\r' {
      new_line lexbuf;
      if !insert_semi then (
        insert_semi := false;
        SEMI
      ) else (
        token lexbuf
      )
    }

  | "//" [^ '\n']*  { token lexbuf }
  | "/*"            { comment lexbuf; token lexbuf }

  | intlit as n  { sop (INT(int64_of_lexeme n)) }
  | ident as id  { sop (keyword_or_ident id) }
  | '"'          { string_lit (Buffer.create 16) lexbuf }

  | ";"  { sop SEMI } | "("  { sop LPAR } | ")"  { sop RPAR }
  | "{"  { sop BEGIN } | "}"  { sop END } | "*"  { sop STAR }
  | "."  { sop POINT } | ","  { sop COMMA }

  | "==" { sop EQ } | "!=" { sop NEQ } | "<=" { sop LE } | ">=" { sop GE }
  | "<"  { sop LT } | ">"  { sop GT } | "&&" { sop AND } | "||" { sop OR }
  | "+"  { sop PLUS } | "-"  { sop MINUS } | "/"  { sop SLASH }
  | "++" { sop PPLUS } | "--" { sop MMINUS }
  | "!"  { sop NOT }  | ":=" { sop DECL } | "="  { sop ASSIGN }
  | "%"  { sop PERCENT } | "fmt.Print" { sop FMTPRINT}

  | _    { raise (Error ("unknown character : " ^ lexeme lexbuf)) }
  | eof  { EOF }

and comment = parse
  | '\n' { new_line lexbuf; comment lexbuf }
  | "*/" { () }
  | _    { comment lexbuf }
  | eof  { raise (Error "unterminated comment") }
and string_lit buf = parse
  | '"'         { sop (STRING (Buffer.contents buf)) }
  | "\\\\"      { Buffer.add_char buf '\\'; string_lit buf lexbuf }
  | "\\\""      { Buffer.add_char buf '"';  string_lit buf lexbuf }
  | "\\n"       { Buffer.add_char buf '\n'; string_lit buf lexbuf }
  | "\\t"       { Buffer.add_char buf '\t'; string_lit buf lexbuf }
  | (['\032'-'\126'] # ['\\' '\"']) as c { Buffer.add_char buf c;    string_lit buf lexbuf }
  | eof         { raise (Error "unterminated string literal") }
  | _           { raise (Error "illegal character in string") }
