%{
	/*
	 Standardisiert über syntaxtree-initial-action.h
	 Einfacher Baum aus Strings, typedef genügt
	 */
#include <iostream>
#include <string>
using namespace std;
#include "tree.hpp"

typedef tree<string> syntaxTree;
syntaxTree * syntaxTree_epsilon_node () {
	return new syntaxTree("$\\epsilon$");
}
int yyerror(string s);
int yylex();
int yylex_2();
#define YYDEBUG 1
%}
%union {syntaxTree * tree;}
%token t_plus t_minus t_mal t_div t_kla_auf t_kla_zu t_fehler t_zahl
%{
	syntaxTree * root;
%}
%initial-action {
#include "syntaxtree-initial-action-bison-3.8.2.h"

} // %initial-action
%%
expr: term | expr t_plus {} term | expr t_minus term;
term: factor | term t_mal factor| term t_div factor;
factor: t_zahl | t_kla_auf expr t_kla_zu | t_minus factor;
%%

#include "lex.yy.c"
#include "syntaxtree-main.cpp"
int yylex() {
	int rc = yylex_2();
	yylval.tree = new syntaxTree(yytext);
	return rc;
}

