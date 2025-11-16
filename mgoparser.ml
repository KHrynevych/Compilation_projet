
type token = 
  | VAR
  | TYPE
  | TRUE
  | STRUCT
  | STRING of (
# 12 "mgoparser.mly"
       (string)
# 11 "mgoparser.ml"
)
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
  | INT of (
# 10 "mgoparser.mly"
       (int64)
# 31 "mgoparser.ml"
)
  | INCR
  | IMPORT
  | IF
  | IDENT of (
# 11 "mgoparser.mly"
       (string)
# 39 "mgoparser.ml"
)
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

# 1 "mgoparser.mly"
  

  open Lexing
  open Mgoast

  exception Error


# 67 "mgoparser.ml"

let menhir_begin_marker =
  0

and (xv_varstyp, xv_prog, xv_option_SEMI_, xv_mgotype, xv_loption_fields_, xv_list_decl_, xv_ident, xv_fields, xv_decl) =
  let _ = fun (_startpos : Lexing.position) (_endpos : Lexing.position) (_endpos__0_ : Lexing.position) (_symbolstartpos : Lexing.position) (_startofs : int) (_endofs : int) (_endofs__0_ : int) (_symbolstartofs : int) (_sloc : Lexing.position * Lexing.position) (_loc : Lexing.position * Lexing.position) (
# 113 "<standard.mly>"
  x
# 76 "mgoparser.ml"
   : unit) (_startpos_x_ : Lexing.position) (_endpos_x_ : Lexing.position) (_startofs_x_ : int) (_endofs_x_ : int) (_loc_x_ : Lexing.position * Lexing.position) : 'tv_option_SEMI_ ->
    
# 114 "<standard.mly>"
    ( Some x )
# 81 "mgoparser.ml"
     in
  let _ = fun (_startpos : Lexing.position) (_endpos : Lexing.position) (_endpos__0_ : Lexing.position) (_symbolstartpos : Lexing.position) (_startofs : int) (_endofs : int) (_endofs__0_ : int) (_symbolstartofs : int) (_sloc : Lexing.position * Lexing.position) (_loc : Lexing.position * Lexing.position) : 'tv_option_SEMI_ ->
    
# 111 "<standard.mly>"
    ( None )
# 87 "mgoparser.ml"
     in
  let _ = fun (_startpos : Lexing.position) (_endpos : Lexing.position) (_endpos__0_ : Lexing.position) (_symbolstartpos : Lexing.position) (_startofs : int) (_endofs : int) (_endofs__0_ : int) (_symbolstartofs : int) (_sloc : Lexing.position * Lexing.position) (_loc : Lexing.position * Lexing.position) (
# 147 "<standard.mly>"
  x
# 92 "mgoparser.ml"
   : 'tv_fields) (_startpos_x_ : Lexing.position) (_endpos_x_ : Lexing.position) (_startofs_x_ : int) (_endofs_x_ : int) (_loc_x_ : Lexing.position * Lexing.position) : 'tv_loption_fields_ ->
    
# 148 "<standard.mly>"
    ( x )
# 97 "mgoparser.ml"
     in
  let _ = fun (_startpos : Lexing.position) (_endpos : Lexing.position) (_endpos__0_ : Lexing.position) (_symbolstartpos : Lexing.position) (_startofs : int) (_endofs : int) (_endofs__0_ : int) (_symbolstartofs : int) (_sloc : Lexing.position * Lexing.position) (_loc : Lexing.position * Lexing.position) : 'tv_loption_fields_ ->
    
# 145 "<standard.mly>"
    ( [] )
# 103 "mgoparser.ml"
     in
  let _ = fun (_startpos : Lexing.position) (_endpos : Lexing.position) (_endpos__0_ : Lexing.position) (_symbolstartpos : Lexing.position) (_startofs : int) (_endofs : int) (_endofs__0_ : int) (_symbolstartofs : int) (_sloc : Lexing.position * Lexing.position) (_loc : Lexing.position * Lexing.position) (
# 218 "<standard.mly>"
         xs
# 108 "mgoparser.ml"
   : 'tv_list_decl_) (_startpos_xs_ : Lexing.position) (_endpos_xs_ : Lexing.position) (_startofs_xs_ : int) (_endofs_xs_ : int) (_loc_xs_ : Lexing.position * Lexing.position) (
# 218 "<standard.mly>"
  x
# 112 "mgoparser.ml"
   : 'tv_decl) (_startpos_x_ : Lexing.position) (_endpos_x_ : Lexing.position) (_startofs_x_ : int) (_endofs_x_ : int) (_loc_x_ : Lexing.position * Lexing.position) : 'tv_list_decl_ ->
    
# 219 "<standard.mly>"
    ( x :: xs )
# 117 "mgoparser.ml"
     in
  let _ = fun (_startpos : Lexing.position) (_endpos : Lexing.position) (_endpos__0_ : Lexing.position) (_symbolstartpos : Lexing.position) (_startofs : int) (_endofs : int) (_endofs__0_ : int) (_symbolstartofs : int) (_sloc : Lexing.position * Lexing.position) (_loc : Lexing.position * Lexing.position) : 'tv_list_decl_ ->
    
# 216 "<standard.mly>"
    ( [] )
# 123 "mgoparser.ml"
     in
  let _ = fun (_startpos : Lexing.position) (_endpos : Lexing.position) (_endpos__0_ : Lexing.position) (_symbolstartpos : Lexing.position) (_startofs : int) (_endofs : int) (_endofs__0_ : int) (_symbolstartofs : int) (_sloc : Lexing.position * Lexing.position) (_loc : Lexing.position * Lexing.position) (
# 57 "mgoparser.mly"
             t
# 128 "mgoparser.ml"
   : 'tv_mgotype) (_startpos_t_ : Lexing.position) (_endpos_t_ : Lexing.position) (_startofs_t_ : int) (_endofs_t_ : int) (_loc_t_ : Lexing.position * Lexing.position) (
# 57 "mgoparser.mly"
     x
# 132 "mgoparser.ml"
   : 'tv_ident) (_startpos_x_ : Lexing.position) (_endpos_x_ : Lexing.position) (_startofs_x_ : int) (_endofs_x_ : int) (_loc_x_ : Lexing.position * Lexing.position) : 'tv_varstyp ->
    
# 57 "mgoparser.mly"
                                     ([(x,t)])
# 137 "mgoparser.ml"
     in
  let _ = fun (_startpos : Lexing.position) (_endpos : Lexing.position) (_endpos__0_ : Lexing.position) (_symbolstartpos : Lexing.position) (_startofs : int) (_endofs : int) (_endofs__0_ : int) (_symbolstartofs : int) (_sloc : Lexing.position * Lexing.position) (_loc : Lexing.position * Lexing.position) (
# 32 "mgoparser.mly"
                                                                 _8
# 142 "mgoparser.ml"
   : unit) (_startpos__8_ : Lexing.position) (_endpos__8_ : Lexing.position) (_startofs__8_ : int) (_endofs__8_ : int) (_loc__8_ : Lexing.position * Lexing.position) (
# 32 "mgoparser.mly"
                                                 decls
# 146 "mgoparser.ml"
   : 'tv_list_decl_) (_startpos_decls_ : Lexing.position) (_endpos_decls_ : Lexing.position) (_startofs_decls_ : int) (_endofs_decls_ : int) (_loc_decls_ : Lexing.position * Lexing.position) (
# 32 "mgoparser.mly"
                                           _6
# 150 "mgoparser.ml"
   : unit) (_startpos__6_ : Lexing.position) (_endpos__6_ : Lexing.position) (_startofs__6_ : int) (_endofs__6_ : int) (_loc__6_ : Lexing.position * Lexing.position) (
# 32 "mgoparser.mly"
                                 fmt
# 154 "mgoparser.ml"
   : (
# 12 "mgoparser.mly"
       (string)
# 158 "mgoparser.ml"
  )) (_startpos_fmt_ : Lexing.position) (_endpos_fmt_ : Lexing.position) (_startofs_fmt_ : int) (_endofs_fmt_ : int) (_loc_fmt_ : Lexing.position * Lexing.position) (
# 32 "mgoparser.mly"
                         _4
# 162 "mgoparser.ml"
   : unit) (_startpos__4_ : Lexing.position) (_endpos__4_ : Lexing.position) (_startofs__4_ : int) (_endofs__4_ : int) (_loc__4_ : Lexing.position * Lexing.position) (
# 32 "mgoparser.mly"
                    _3
# 166 "mgoparser.ml"
   : unit) (_startpos__3_ : Lexing.position) (_endpos__3_ : Lexing.position) (_startofs__3_ : int) (_endofs__3_ : int) (_loc__3_ : Lexing.position * Lexing.position) (
# 32 "mgoparser.mly"
          main
# 170 "mgoparser.ml"
   : (
# 11 "mgoparser.mly"
       (string)
# 174 "mgoparser.ml"
  )) (_startpos_main_ : Lexing.position) (_endpos_main_ : Lexing.position) (_startofs_main_ : int) (_endofs_main_ : int) (_loc_main_ : Lexing.position * Lexing.position) (
# 32 "mgoparser.mly"
 _1
# 178 "mgoparser.ml"
   : unit) (_startpos__1_ : Lexing.position) (_endpos__1_ : Lexing.position) (_startofs__1_ : int) (_endofs__1_ : int) (_loc__1_ : Lexing.position * Lexing.position) : (
# 22 "mgoparser.mly"
      (Mgoast.program)
# 182 "mgoparser.ml"
  ) ->
    (
# 33 "mgoparser.mly"
    ( if main="main" && fmt="fmt" then (true, decls) else raise Error)
# 187 "mgoparser.ml"
     : 'tv_prog) in
  let _ = fun (_startpos : Lexing.position) (_endpos : Lexing.position) (_endpos__0_ : Lexing.position) (_symbolstartpos : Lexing.position) (_startofs : int) (_endofs : int) (_endofs__0_ : int) (_symbolstartofs : int) (_sloc : Lexing.position * Lexing.position) (_loc : Lexing.position * Lexing.position) (
# 30 "mgoparser.mly"
                                          _5
# 192 "mgoparser.ml"
   : unit) (_startpos__5_ : Lexing.position) (_endpos__5_ : Lexing.position) (_startofs__5_ : int) (_endofs__5_ : int) (_loc__5_ : Lexing.position * Lexing.position) (
# 30 "mgoparser.mly"
                          decls
# 196 "mgoparser.ml"
   : 'tv_list_decl_) (_startpos_decls_ : Lexing.position) (_endpos_decls_ : Lexing.position) (_startofs_decls_ : int) (_endofs_decls_ : int) (_loc_decls_ : Lexing.position * Lexing.position) (
# 30 "mgoparser.mly"
                    _3
# 200 "mgoparser.ml"
   : unit) (_startpos__3_ : Lexing.position) (_endpos__3_ : Lexing.position) (_startofs__3_ : int) (_endofs__3_ : int) (_loc__3_ : Lexing.position * Lexing.position) (
# 30 "mgoparser.mly"
          main
# 204 "mgoparser.ml"
   : (
# 11 "mgoparser.mly"
       (string)
# 208 "mgoparser.ml"
  )) (_startpos_main_ : Lexing.position) (_endpos_main_ : Lexing.position) (_startofs_main_ : int) (_endofs_main_ : int) (_loc_main_ : Lexing.position * Lexing.position) (
# 30 "mgoparser.mly"
 _1
# 212 "mgoparser.ml"
   : unit) (_startpos__1_ : Lexing.position) (_endpos__1_ : Lexing.position) (_startofs__1_ : int) (_endofs__1_ : int) (_loc__1_ : Lexing.position * Lexing.position) : (
# 22 "mgoparser.mly"
      (Mgoast.program)
# 216 "mgoparser.ml"
  ) ->
    (
# 31 "mgoparser.mly"
    ( if main="main" then (false, decls) else raise Error)
# 221 "mgoparser.ml"
     : 'tv_prog) in
  let _ = fun (_startpos : Lexing.position) (_endpos : Lexing.position) (_endpos__0_ : Lexing.position) (_symbolstartpos : Lexing.position) (_startofs : int) (_endofs : int) (_endofs__0_ : int) (_symbolstartofs : int) (_sloc : Lexing.position * Lexing.position) (_loc : Lexing.position * Lexing.position) (
# 47 "mgoparser.mly"
    s
# 226 "mgoparser.ml"
   : (
# 11 "mgoparser.mly"
       (string)
# 230 "mgoparser.ml"
  )) (_startpos_s_ : Lexing.position) (_endpos_s_ : Lexing.position) (_startofs_s_ : int) (_endofs_s_ : int) (_loc_s_ : Lexing.position * Lexing.position) : 'tv_mgotype ->
    
# 47 "mgoparser.mly"
                  (
                    match s with
                    | "int"    -> TInt
                    | "bool"   -> TBool
                    | "string" -> TString
                    | _        -> TStruct s
                    )
# 241 "mgoparser.ml"
     in
  let _ = fun (_startpos : Lexing.position) (_endpos : Lexing.position) (_endpos__0_ : Lexing.position) (_symbolstartpos : Lexing.position) (_startofs : int) (_endofs : int) (_endofs__0_ : int) (_symbolstartofs : int) (_sloc : Lexing.position * Lexing.position) (_loc : Lexing.position * Lexing.position) (
# 46 "mgoparser.mly"
         s
# 246 "mgoparser.ml"
   : (
# 11 "mgoparser.mly"
       (string)
# 250 "mgoparser.ml"
  )) (_startpos_s_ : Lexing.position) (_endpos_s_ : Lexing.position) (_startofs_s_ : int) (_endofs_s_ : int) (_loc_s_ : Lexing.position * Lexing.position) (
# 46 "mgoparser.mly"
   _1
# 254 "mgoparser.ml"
   : unit) (_startpos__1_ : Lexing.position) (_endpos__1_ : Lexing.position) (_startofs__1_ : int) (_endofs__1_ : int) (_loc__1_ : Lexing.position * Lexing.position) : 'tv_mgotype ->
    
# 46 "mgoparser.mly"
                  ( TStruct(s) )
# 259 "mgoparser.ml"
     in
  let _ = fun (_startpos : Lexing.position) (_endpos : Lexing.position) (_endpos__0_ : Lexing.position) (_symbolstartpos : Lexing.position) (_startofs : int) (_endofs : int) (_endofs__0_ : int) (_symbolstartofs : int) (_sloc : Lexing.position * Lexing.position) (_loc : Lexing.position * Lexing.position) (
# 37 "mgoparser.mly"
  id
# 264 "mgoparser.ml"
   : (
# 11 "mgoparser.mly"
       (string)
# 268 "mgoparser.ml"
  )) (_startpos_id_ : Lexing.position) (_endpos_id_ : Lexing.position) (_startofs_id_ : int) (_endofs_id_ : int) (_loc_id_ : Lexing.position * Lexing.position) : 'tv_ident ->
    
# 37 "mgoparser.mly"
             ( { loc = _startpos, _endpos; id = id } )
# 273 "mgoparser.ml"
     in
  let _ = fun (_startpos : Lexing.position) (_endpos : Lexing.position) (_endpos__0_ : Lexing.position) (_symbolstartpos : Lexing.position) (_startofs : int) (_endofs : int) (_endofs__0_ : int) (_symbolstartofs : int) (_sloc : Lexing.position * Lexing.position) (_loc : Lexing.position * Lexing.position) (
# 61 "mgoparser.mly"
                  xtl
# 278 "mgoparser.ml"
   : 'tv_fields) (_startpos_xtl_ : Lexing.position) (_endpos_xtl_ : Lexing.position) (_startofs_xtl_ : int) (_endofs_xtl_ : int) (_loc_xtl_ : Lexing.position * Lexing.position) (
# 61 "mgoparser.mly"
            _2
# 282 "mgoparser.ml"
   : unit) (_startpos__2_ : Lexing.position) (_endpos__2_ : Lexing.position) (_startofs__2_ : int) (_endofs__2_ : int) (_loc__2_ : Lexing.position * Lexing.position) (
# 61 "mgoparser.mly"
  xt
# 286 "mgoparser.ml"
   : 'tv_varstyp) (_startpos_xt_ : Lexing.position) (_endpos_xt_ : Lexing.position) (_startofs_xt_ : int) (_endofs_xt_ : int) (_loc_xt_ : Lexing.position * Lexing.position) : 'tv_fields ->
    
# 61 "mgoparser.mly"
                                ( xt :: xtl )
# 291 "mgoparser.ml"
     in
  let _ = fun (_startpos : Lexing.position) (_endpos : Lexing.position) (_endpos__0_ : Lexing.position) (_symbolstartpos : Lexing.position) (_startofs : int) (_endofs : int) (_endofs__0_ : int) (_symbolstartofs : int) (_sloc : Lexing.position * Lexing.position) (_loc : Lexing.position * Lexing.position) (
# 60 "mgoparser.mly"
            _2
# 296 "mgoparser.ml"
   : 'tv_option_SEMI_) (_startpos__2_ : Lexing.position) (_endpos__2_ : Lexing.position) (_startofs__2_ : int) (_endofs__2_ : int) (_loc__2_ : Lexing.position * Lexing.position) (
# 60 "mgoparser.mly"
  xt
# 300 "mgoparser.ml"
   : 'tv_varstyp) (_startpos_xt_ : Lexing.position) (_endpos_xt_ : Lexing.position) (_startofs_xt_ : int) (_endofs_xt_ : int) (_loc_xt_ : Lexing.position * Lexing.position) : 'tv_fields ->
    
# 60 "mgoparser.mly"
                                ( [xt]      )
# 305 "mgoparser.ml"
     in
  let _ = fun (_startpos : Lexing.position) (_endpos : Lexing.position) (_endpos__0_ : Lexing.position) (_symbolstartpos : Lexing.position) (_startofs : int) (_endofs : int) (_endofs__0_ : int) (_symbolstartofs : int) (_sloc : Lexing.position * Lexing.position) (_loc : Lexing.position * Lexing.position) (
# 41 "mgoparser.mly"
                                                  _7
# 310 "mgoparser.ml"
   : unit) (_startpos__7_ : Lexing.position) (_endpos__7_ : Lexing.position) (_startofs__7_ : int) (_endofs__7_ : int) (_loc__7_ : Lexing.position * Lexing.position) (
# 41 "mgoparser.mly"
                                              _6
# 314 "mgoparser.ml"
   : unit) (_startpos__6_ : Lexing.position) (_endpos__6_ : Lexing.position) (_startofs__6_ : int) (_endofs__6_ : int) (_loc__6_ : Lexing.position * Lexing.position) (
# 41 "mgoparser.mly"
                            fl
# 318 "mgoparser.ml"
   : 'tv_loption_fields_) (_startpos_fl_ : Lexing.position) (_endpos_fl_ : Lexing.position) (_startofs_fl_ : int) (_endofs_fl_ : int) (_loc_fl_ : Lexing.position * Lexing.position) (
# 41 "mgoparser.mly"
                     _4
# 322 "mgoparser.ml"
   : unit) (_startpos__4_ : Lexing.position) (_endpos__4_ : Lexing.position) (_startofs__4_ : int) (_endofs__4_ : int) (_loc__4_ : Lexing.position * Lexing.position) (
# 41 "mgoparser.mly"
              _3
# 326 "mgoparser.ml"
   : unit) (_startpos__3_ : Lexing.position) (_endpos__3_ : Lexing.position) (_startofs__3_ : int) (_endofs__3_ : int) (_loc__3_ : Lexing.position * Lexing.position) (
# 41 "mgoparser.mly"
      id
# 330 "mgoparser.ml"
   : 'tv_ident) (_startpos_id_ : Lexing.position) (_endpos_id_ : Lexing.position) (_startofs_id_ : int) (_endofs_id_ : int) (_loc_id_ : Lexing.position * Lexing.position) (
# 40 "mgoparser.mly"
     _1
# 335 "mgoparser.ml"
   : unit) (_startpos__1_ : Lexing.position) (_endpos__1_ : Lexing.position) (_startofs__1_ : int) (_endofs__1_ : int) (_loc__1_ : Lexing.position * Lexing.position) : 'tv_decl ->
    
# 42 "mgoparser.mly"
  ( Struct { sname = id; fields = List.flatten fl; } )
# 340 "mgoparser.ml"
     in
  ((let rec diverge() = diverge() in diverge()) : 'tv_varstyp * 'tv_prog * 'tv_option_SEMI_ * 'tv_mgotype * 'tv_loption_fields_ * 'tv_list_decl_ * 'tv_ident * 'tv_fields * 'tv_decl)

and menhir_end_marker =
  0
