#include <cstdio>
extern "C" {
  #include "jsonpath.tab.c"
#include "lex.yy.c"
  int yyparse();            // bison parser
  int yylex();              // flex lexer
  void yyrestart(FILE*);    // optional
  YY_BUFFER_STATE yy_scan_string(const char*);
  void yy_delete_buffer(YY_BUFFER_STATE);
  extern FILE* yyin;
}

int main() {
  const char *input = "$ .a\n";   // Beispiel‑Query
  YY_BUFFER_STATE buf = yy_scan_string(input);
  yyparse();                       // parst die aktuelle Buffer‑Eingabe
  yy_delete_buffer(buf);
  return 0;
}
