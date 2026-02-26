%{
/*
 Standardisiert über syntaxtree-initial-action.h
 Eigene Klasse syntaxTree, hier abgeleitet aus tree.hpp
 */
#include <iostream>
#include <string>
using namespace std;
#include "tree.hpp"

class syntaxTreeNode {
	public:
	syntaxTreeNode(const string & _txt = "", int _token = -1) : txt(_txt), token(_token) {}
	friend ostream & operator << (ostream & o, const syntaxTreeNode & n);
	protected:
	string txt;
	int token;
};
	
class syntaxTree : public tree<syntaxTreeNode> {
	public:
	syntaxTree(const string & txt, int token = -1)  {v = syntaxTreeNode(txt, token);}
	syntaxTree(const syntaxTreeNode & n) {v = n;}
};


ostream & operator << (ostream & o, const syntaxTreeNode & n) {
	if (n.token > 0) // Terminal
	o << n.token << ": ";
	o << n.txt;
	return o;
}

syntaxTree * syntaxTree_epsilon_node ();
int yylex();
int yylex_2();
int yyerror(string s);
#define YYDEBUG 1
%}
%union {syntaxTree * tree;}
%token t_plus t_minus t_mal t_div t_kla_auf t_kla_zu t_fehler t_zahl t_epsilon
%{
	syntaxTree * root;
%}
%initial-action {
#include "syntaxtree-initial-action-bison-3.8.2.h"
#undef YYLEX
#define YYLEX yylex2()
} // %initial-action
%%
expr: term | expr t_plus {} term | expr t_minus term;
term: factor | term t_mal factor| term t_div factor;
factor: t_zahl | t_kla_auf expr t_kla_zu | t_minus factor;
%%
syntaxTree * syntaxTree_epsilon_node () {
	//	extern int  t_epsilon;
	return new syntaxTree("$\\epsilon$", t_epsilon);
}

#include "lex.yy.c"
#include "syntaxtree-main.cpp"
int yylex() {
	int rc = yylex_2();
	yylval.tree = new syntaxTree(yytext);
	return rc;
}
