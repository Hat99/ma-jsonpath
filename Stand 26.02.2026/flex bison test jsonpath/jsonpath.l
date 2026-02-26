%option noyywrap

%{
#include <stdio.h>

#define YY_DECL int yylex()

#include "jsonpath.tab.h"

%}

%%

"$"     {return T_ROOT;}
"@"     {return T_CURRENT;}
".."	{return T_DESCENDANT;}
"."		{return T_DOT;}
.       {return T_DUMMY;}

%%