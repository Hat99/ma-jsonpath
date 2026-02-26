%{
/*
 Standardisiert über syntaxtree-initial-action.h
 Eigene Klasse syntaxTree, hier abgeleitet aus tree.hpp

 Polymorphe abstrakte Klasse syntaxTreeNode
 Zwei abgeleitete Klassen für Terminal und Nonterminal
 syntaxTree hat Zeiger auf syntaxTreeNode wegen Polymorphismus
 Über Konstruktoren wird konkreter Typ geregelt
 Ausgabeoperator << ruft polymorph die jeweilig passende tikz-Methode auf
 */
#include <iostream>
#include <string>
using namespace std;
#include "tree.hpp"

class syntaxTreeNode {
	public:
	virtual void tikz(ostream & o) const  = 0;
};
	
class syntaxTreeNodeTerminal : public syntaxTreeNode {
	public:
	syntaxTreeNodeTerminal(string _txt, int _token) : txt(_txt), token(_token) {}
	virtual void tikz(ostream & o) const { o << token <<": "<< txt;}
	protected:
	string txt;
	int token;
};

class syntaxTreeNodeNonterminal : public syntaxTreeNode {
	public:
	syntaxTreeNodeNonterminal(string _txt) : txt(_txt) {}
	virtual void tikz(ostream & o) const {o << txt;}
	protected:
	string txt;
};

class syntaxTree : public tree<syntaxTreeNode *> {
	public:
	// Der folgende Konstruktor wird im Scanner aufgerufen und erzeugt Terminalknoten
	syntaxTree(string txt, int token) {v = new syntaxTreeNodeTerminal(txt, token);}
	
	// Der folgende Konstruktor wird im Parser aufgerufen und erzeugt Nonterminalknoten
	syntaxTree(string txt) {v = new syntaxTreeNodeNonterminal(txt);}
	
	// Ggf wäre für Erweiterungen sinnvoll:
	syntaxTree(syntaxTreeNode * _v) {v = _v;} // Nicht getestet!!! in diesem Beispiel nicht drin!!!
	/* Aber Achtung, die include-Datei syntaxtree-initial-action.h erwartet weiterhin
	 Konstruktor syntaxTree(char *)
	 */
	
};

ostream & operator << (ostream & o, const syntaxTreeNode * n) {
	n->tikz(o);
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
	return new syntaxTree("$\\epsilon$", t_epsilon);
}

#include "lex.yy.c"
#include "syntaxtree-main.cpp"
int yylex() {
	int rc = yylex_2();
	yylval.tree = new syntaxTree(yytext, rc);
	return rc;
}
