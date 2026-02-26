#include <stdio.h>
#include <string.h>
#include "tree.h"
#include "parser.tab.h"  // For tokens, YYSTYPE, yyparse, etc.
#include "compiler.h"

extern int yyparse();
extern void* yy_scan_string(const char* str);
extern void yy_delete_buffer(void* buffer);
extern TreeNode* root;

int main() {
    char input[1024];

    printf("Enter JSONPath expression:");
    if (fgets(input, sizeof(input), stdin)) {
        size_t len = strlen(input);
        if (len > 0 && input[len - 1] == '\n') {
            input[len - 1] = '\0';
        }

        void* buffer = yy_scan_string(input);

        int res = yyparse();

        // printf("Parse result: %d\n\n", res);
        if (res != 0) {
            fprintf(stderr, "Parsing failed.\n");
            yy_delete_buffer(buffer);
            return 1;
        }
        else {
            printf("\nParsing succeeded.\n");
            printf("\nSyntax Tree:\n");
            printTree(root, 0);
            printf("\nYottaDB Global Reference:");
            compileToYottoDB(root, stdout);
        }
        

        yy_delete_buffer(buffer);
    }

    return 0;
}
