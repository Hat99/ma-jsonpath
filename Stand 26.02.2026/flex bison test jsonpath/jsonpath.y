%{

#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);
%}


%token T_ROOT T_CURRENT
%token T_DESCENDANT T_DOT
%token T_DUMMY


%start jsonpath_query

%%

jsonpath_query: 
    T_ROOT segments 
;

segments:
    T_DUMMY {printf("\tDummy Token found\n");}
;

%%

int main() {
	yyin = stdin;

	do {
		yyparse();
	} while(!feof(yyin));

	return 0;
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}