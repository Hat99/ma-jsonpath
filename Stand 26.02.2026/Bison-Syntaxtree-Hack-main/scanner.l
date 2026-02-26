%{
#define YY_DECL int yylex_2()
%}
%%
"+"         return t_plus;
"-"         return t_minus;
"*"         return t_mal;
"/"         return t_div;
"("         return t_kla_auf;
")"         return t_kla_zu;
[0-9]+      return t_zahl;
[ \t\n]     /* do nothing */;
.           return t_fehler;
%%
int yywrap(void) {
	return 1;
}
