%debug

%define api.pure full
%define api.value.type { union JsonpathValue }
%define parse.error verbose


%parse-param { yyscan_t scanner }
%parse-param { ASTNode **result }
%lex-param   { yyscan_t scanner }

%code requires {
  #include "lib/ast.h"

  typedef void* yyscan_t;

  union JsonpathValue {
    ASTNode* node;
    char* str;
    double num;   //später nötig für Literale
  };
}

%code {
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  int yylex(YYSTYPE *yylval_param, yyscan_t scanner); 
  void yyerror(yyscan_t scanner, ASTNode **result, const char *msg);

  /* Einheitliches Abbruch-Makro für nicht implementierte/unerlaubte Konstrukte */
  #define REJECT(MSG) do { yyerror(scanner, result, (MSG)); YYERROR; } while (0)
}

/* ---- Typen der Nonterminals ---- */
%type <node> jsonpath path member subscript sub_expr array_index member_name

/* ---- Tokens mit Werten ---- */
%token <str> NAME STRING INT NUMBER TRUE FALSE NULLVAL

/* ---- Struktur-Tokens ---- */
%token DOLLAR AT DOT DOTDOT STAR
%token LBRACK RBRACK LPAREN RPAREN COMMA COLON QUESTION
%token EQ NE LT LE GT GE AND OR

/* (für spätere Filter hilfreich) */
%left OR
%left AND
%left EQ NE LT LE GT GE

%%

/* Startsymbol: kompletter JSONPath */
jsonpath:
    DOLLAR path   { ASTNode *dollar = make_node(AST_IDENTIFIER, NULL, NULL, "$");
                  *result = make_node(AST_PATH, dollar, $2, NULL);  }
    | /* leer */  { yyerror(scanner, result, "Leerer JSONPath-Ausdruck ist nicht erlaubt"); YYERROR; }
  ;


/* Sequenz aus .member oder [subscript]; rekursiver Deszent wird sofort abgelehnt */
path:
      member path              { $$ = make_node(AST_PATH, $1, $2, NULL); }
    | subscript path           { $$ = make_node(AST_PATH, $1, $2, NULL); }
    | DOTDOT                   { $$ = NULL; yyerror(scanner, result, "Rekursiver Deszent (..) ist nicht unterstützt"); YYERROR; }
    | /* leer */               { $$ = NULL; }
    ;


/* .name ist erlaubt; .*, also Wildcard nach Punkt, wird abgelehnt */
member:
      DOT NAME                   { $$ = make_node(AST_IDENTIFIER, NULL, NULL, $2); }
    | DOT STAR                   { $$ = NULL; REJECT("Wildcard (*) im Objektzugriff ist nicht unterstützt"); }
    ;


/* [ ... ]-Klammern */
subscript:
      LBRACK sub_expr RBRACK     { $$ = $2; }
    ;


/* Erlaubt: [INT] (Index), ["name"] (Feldname) */
/* Abgelehnt: [*], [?, : , , ...] */
sub_expr:
      array_index              { $$ = $1; }
    | member_name              { $$ = $1; }
    | STAR                     { $$ = NULL; yyerror(scanner, result, "Wildcard ([*]) ist nicht unterstützt"); YYERROR; }
    | QUESTION                 { $$ = NULL; yyerror(scanner, result, "Filter (?()) sind nicht unterstützt"); YYERROR; }
    | COLON                    { $$ = NULL; yyerror(scanner, result, "Array-Slices ([start:end[:step]]) sind nicht unterstützt"); YYERROR; }
    | COMMA                    { $$ = NULL; yyerror(scanner, result, "Union (x,y,...) ist nicht unterstützt"); YYERROR; }
    ;


/* Nur ganzzahlige, nicht-negative Indizes sind erlaubt: [INT] */
/* Alles andere, was wie Zahl aussieht (NUMBER), wird abgelehnt */
array_index:
      INT                       { $$ = make_node(AST_LITERAL, NULL, NULL, $1); }
    | NUMBER                    { $$ = NULL; REJECT("Index [n] erwartet (ganzzahlig, >= 0)"); }
    ;

/* ["name"] → Feldname (kein Index!) */
member_name:
      STRING                    { $$ = make_node(AST_IDENTIFIER, NULL, NULL, $1); }
    ;


%%


void yyerror(yyscan_t scanner, ASTNode **result, const char *msg) {
    (void)scanner; (void)result;
    if (strstr(msg, "unexpected COLON")) {
        fprintf(stderr, "Syntaxfehler: Array-Slices ([start:end[:step]]) sind nicht unterstützt\n");
    } else {
        fprintf(stderr, "Syntaxfehler: %s\n", msg);
    }
}

