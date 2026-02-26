%{
#include "tree.h"
#include <stdio.h>
#include <stdlib.h>

TreeNode* root;
int yylex();
void yyerror(const char* s) { fprintf(stderr, "Error: %s\n", s); }
%}

%union {
    TreeNode* node;
    int num;
    char* str;
}

%token ROOT "$"
%token DOT "."
%token DOT_DOT ".."
%token STAR "*"
%token COLON ":"
%token <num> NUMBER
%token <str> IDENTIFIER

%type <node> jsonpath path_item path_item_element child_access recursive_access array_index wildcard

%define parse.error verbose
%debug

%%

jsonpath:
      ROOT path_item {
          // printf("Parsed ROOT\n");
          $$ = createNode("ROOT", "$", 1, $2);
          root = $$;
      }
    ;

path_item:
      /* empty */ {
          // printf("Empty path_item\n");
          $$ = NULL;
      }
    | path_item path_item_element {
          // printf("Non-empty path_item\n");
          if ($1 == NULL)
              $$ = $2;
          else
              $$ = createNode("PATH_ITEM", NULL, 2, $1, $2);
      }
    ;

path_item_element:
      child_access
    | recursive_access
    ;

child_access:
      DOT IDENTIFIER {
          // printf("Child access IDENTIFIER: %s\n", $2);
          $$ = createNode("IDENTIFIER", $2, 0);
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
          // printf("Recursive descent IDENTIFIER: %s\n", $2);
          $$ = createNode("RECURSIVE_DESCENT", $2, 0);
          free($2);
      }
    | DOT_DOT wildcard {
          $$ = $2;
      }
    ;

array_index:
      '[' NUMBER COLON NUMBER ']' {
          char buf[64];
          snprintf(buf, sizeof(buf), "%d:%d", $2, $4);
          $$ = createNode("ARRAY_SLICE", buf, 0);
      }
      | '[' NUMBER COLON NUMBER COLON NUMBER ']' {
          char buf[128];
          snprintf(buf, sizeof(buf), "%d:%d:%d", $2, $4, $6);
          $$ = createNode("ARRAY_SLICE", buf, 0);
      }
      | '[' NUMBER ']' {
          char buf[32];
          snprintf(buf, sizeof(buf), "%d", $2);
          // printf("Array index: %s\n", buf);
          $$ = createNode("ARRAY_INDEX", buf, 0);
      }
    ;

wildcard:
      '[' STAR ']' {
          // printf("Wildcard\n");
          $$ = createNode("WILDCARD", "*", 0);
      }
    ;

%%
