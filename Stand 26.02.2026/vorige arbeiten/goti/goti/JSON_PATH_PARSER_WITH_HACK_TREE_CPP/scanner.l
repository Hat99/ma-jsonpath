%{
#define f(t) yylval.tree = new syntaxTree(yytext); return t;
%}

DIGIT      [0-9]
ID_START   [a-zA-Z_]
ID_CONT    [a-zA-Z0-9_]

%%

[$]           f(ROOT)
".."          f(DOT_DOT)
[.]           f(DOT)
[*]           f(STAR)
"["           f('[')
"]"           f(']')
":"           f(COLON)
{DIGIT}+       f(NUMBER)

{ID_START}{ID_CONT}*  f(IDENTIFIER)

[ \t\n\f\r]+     /* do nothing */;
.           f(FEHLER)
<<EOF>> return 0;
%%
int yywrap() {
	return 1;
}

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