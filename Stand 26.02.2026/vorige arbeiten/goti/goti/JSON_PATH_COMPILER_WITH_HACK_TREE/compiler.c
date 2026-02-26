#include "tree.h"
#include <stdio.h>
#include <string.h>
void compileToYottoDB(TreeNode* node, FILE* output) {
    if (!node) return;

    if (strcmp(node->type, "ROOT") == 0) {
        fprintf(output, "^store");
        for (int i = 0; i < node->childCount; i++) {
            compileToYottoDB(node->children[i], output);
        }
        fprintf(output, "\n");
    }
    else if (strcmp(node->type, "PATH_ITEM") == 0) {
        for (int i = 0; i < node->childCount; i++) {
            compileToYottoDB(node->children[i], output);
        }
    }
    else if (strcmp(node->type, "IDENTIFIER") == 0) {
        fprintf(output, "(\"%s\")", node->value);
    }
    else if (strcmp(node->type, "ARRAY_INDEX") == 0) {
        fprintf(output, "(%s)", node->value);
    }
    else if (strcmp(node->type, "ARRAY_SLICE") == 0) {
        fprintf(output, "(\"%s\")", node->value);
    }
    else if (strcmp(node->type, "WILDCARD") == 0) {
        fprintf(output, "(\"*\")");
    }
    else {
        for (int i = 0; i < node->childCount; i++) {
            compileToYottoDB(node->children[i], output);
        }
    }
}
