{

  open Lexing
  open Mgoparser

  exception Error of string

  let keyword_or_ident =
    let h = Hashtbl.create 23 in
    List.iter (fun (s, k) -> Hashtbl.add h s k)
      [ "package",    PACKAGE;
        "import",     IMPORT;
        "type",       TYPE;      
        "struct",     STRUCT;    
        "else",       ELSE;
        "false",      FALSE;
        "for",        FOR;
        "func",       FUNC;
        "if",         IF;
        "nil",        NIL;
        "return",     RETURN;
        "true",       TRUE;
        "var",        VAR
      ] ;
    fun s -> match Hashtbl.find_opt h s with some k -> k
                                            | None -> IDENT s
    let max_i64 = Int64.max_int64

    let int64_of_lexeme s =
      try
        let n = Int64.of_string s in
        if n < Int64.zero || n > max_i64 then raise Exit; n
      with _ -> raise (Error "invalid or out-of-range integer literal")      
}

let digit = ['0'-'9']
let number = digit+
let alpha = ['a'-'z' 'A'-'Z' '_']
let ident = alpha (alpha | digit)*
let fmt = "fmt" 
let hexa = ['0'-'9' 'a'-'f' 'A'-'F']
let int = digit+ | ('0''x' | '0''X') (hexa)+
let car = [' '-'!'] | ['#'-'['] | [']'-'~'] | '\\''\\' | '\\''"' | '\\''n' | '\\''t'
let string = '"' car* '"'
  
rule token = parse
  | ['\n']            { new_line lexbuf; token lexbuf }
  | [' ' '\t' '\r']+  { token lexbuf }

  | "/*"              { comment lexbuf; token lexbuf }

  | '"' fmt '"'       { STRING("fmt") }

  | number as n  { try INT(Int64.of_string n) 
                   with _ -> raise (Error "literal constant too large") }
  | ident as id  { keyword_or_ident id }

  | ";"  { SEMI }
  | "("  { LPAR }
  | ")"  { RPAR }
  | "{"  { BEGIN }
  | "}"  { END }
  | "*"  { STAR }
  | "."  { POINT }
  | ","  { COMMA }

  | "==" { EQ }
  | "!=" { NQ }
  | "<=" { LE }
  | ">=" { GE }
  | "<"  { LT }
  | ">"  { GT }
  | "&&" { AND }
  | "||" { OR }
  | "+"  { PLUS }
  | "-"  { MINUS }
  | "/"  { SLASH }
  | "++" { PPLUS }
  | "--" { MMINUS }
  | "!"  { NOT }
  | "="  { ASSIGN }
  | ":=" { DECL }
  | "%"  { PERCENT }


  | _    { raise (Error ("unknown character : " ^ lexeme lexbuf)) }
  | eof  { EOF }

and comment = parse
  | '\n' { new_line lexbuf; comment lexbuf }
  | "*/" { () }
  | _    { comment lexbuf }
  | eof  { raise (Error "unterminated comment") }
