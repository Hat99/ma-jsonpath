%{
#include "tree.hpp"
#include <iostream>
#include <string>
using namespace std;
typedef tree<string> syntaxTree;

syntaxTree * root;

int yylex();
void yyerror(const char * const );
%}
%union {
    syntaxTree * tree;
    int num;
    char* str;
}
%token <tree> ROOT DOT DOT_DOT STAR COLON NUMBER IDENTIFIER FEHLER
%type <tree> jsonpath path_item path_item_element child_access recursive_access array_index wildcard 

%define parse.error verbose
%debug

%%

jsonpath:
      ROOT path_item {
          $$ = new syntaxTree("ROOT", $2);
          root = $$;
      }
    ;

path_item:
    /* empty */ {
          $$ = NULL;
      }
    | path_item_element path_item  {
          // printf("Non-empty path_item\n");
          if ($2 == NULL)
              $$ = $1;
          else
              $$ = new syntaxTree("PATH_ITEM", $1, $2);
      }
    ;

path_item_element:
      child_access
    | recursive_access
    ;

child_access:
      DOT IDENTIFIER {
          char buf[128];
          snprintf(buf, sizeof(buf), " IDENTIFIER: %s", $2->get().c_str());
          $$ = new syntaxTree(buf);
          free($2);
      }
    | array_index {
          $$ = $1;
      }
    | wildcard {
          $$ = $1;
      }
    ;

recursive_access:
      DOT_DOT IDENTIFIER {
          char buf[128];
          // printf("Recursive descent IDENTIFIER: %s\n", $2);
          snprintf(buf, sizeof(buf), "RECURSIVE_DESCENT: %s", $2->get().c_str());
          $$ = new syntaxTree(buf);
          free($2);
      }
    | DOT_DOT wildcard {
          $$ = $2;
      }
    ;

array_index:
      '[' NUMBER COLON NUMBER ']' {
          char buf[128];
          snprintf(buf, sizeof(buf), " ARRAY_SLICE: %s:%s", $2->get().c_str(), $4->get().c_str());
          $$ = new syntaxTree(buf);
      }
      | '[' NUMBER COLON NUMBER COLON NUMBER ']' {
          char buf[128];
          snprintf(buf, sizeof(buf), "ARRAY_SLICE: %s:%s:%s", $2->get().c_str(), $4->get().c_str(), $6->get().c_str());
          $$ = new syntaxTree(buf);
      }
      | '[' NUMBER ']' {
          char buf[128];
          snprintf(buf, sizeof(buf), "ARRAY_SLICE: %s", $2->get().c_str());
          $$ = new syntaxTree(buf);
      }
    ;

wildcard:
      '[' STAR ']' {
          // printf("Wildcard\n");
          $$ = new syntaxTree("WILDCARD: *");
      }
    ;

%%

#include "lex.yy.c"

int main() {
	if (!yyparse())
		root->tikz();
	return 0;
}

void yyerror(const char * const t) {
	cout << t << endl;
}