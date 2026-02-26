%option noyywrap nounput noinput

%{
#include "tree.h"
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
%}

DIGIT      [0-9]
ID_START   [a-zA-Z_]
ID_CONT    [a-zA-Z0-9_]

%%

[$]           { return ROOT; }
".."          { return DOT_DOT; }
[.]           { return DOT; }
[*]           { return STAR; }
"["           { return '['; }
"]"           { return ']'; }
":"    { return COLON; }

{DIGIT}+       {
                  yylval.num = atoi(yytext);
                  return NUMBER;
               }

{ID_START}{ID_CONT}*  {
                  yylval.str = strdup(yytext);
                  return IDENTIFIER;
               }

[ \t\r\n]+     ;  /* skip whitespace */

.              { 
                  fprintf(stderr, "Unexpected character: %s\n", yytext);
                  return yytext[0];
               }


%%
/*
Tokens extracted:

- ROOT        ('$')          : Indicates the root object in JSONPath.
- DOT_DOT     ('..')         : Recursive descent operator to search descendants.
- DOT         ('.')          : Child access operator to access immediate children.
- STAR        ('*')          : Wildcard to match all properties or array elements.
- '[' and ']'                 : Delimit array indices, slices, or filters.
- NUMBER      (e.g. '123')   : Numeric index for arrays.
- IDENTIFIER  (e.g. 'store') : Property or key names in objects.

Whitespace characters (space, tab, newline) are skipped.

Any unexpected characters are reported as errors.
*/