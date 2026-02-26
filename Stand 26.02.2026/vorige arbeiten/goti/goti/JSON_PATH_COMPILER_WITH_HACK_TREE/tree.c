// tree.c
#include "tree.h"
#include <stdarg.h>

TreeNode* createNode(const char* type, const char* value, int childCount, ...) {
    TreeNode* node = (TreeNode*)malloc(sizeof(TreeNode));
    node->type = strdup(type);
    node->value = value ? strdup(value) : NULL;
    node->childCount = childCount;
    node->children = (TreeNode**)malloc(sizeof(TreeNode*) * childCount);

    va_list args;
    va_start(args, childCount);
    for (int i = 0; i < childCount; ++i) {
        node->children[i] = va_arg(args, TreeNode*);
    }
    va_end(args);

    return node;
}

void printTree(TreeNode* root, int depth) {
    if (!root) return;
    for (int i = 0; i < depth; ++i) printf("  ");
    printf("%s", root->type);
    if (root->value) printf(": %s", root->value);
    printf("\n");

    for (int i = 0; i < root->childCount; ++i)
        printTree(root->children[i], depth + 1);
}
