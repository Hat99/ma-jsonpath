#ifndef TREE_H
#define TREE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct TreeNode {
    char* type;              // e.g., "EXPR", "NUM", "OP"
    char* value;             // e.g., "+", "42"
    struct TreeNode** children;
    int childCount;
} TreeNode;

TreeNode* createNode(const char* type, const char* value, int childCount, ...);
void printTree(TreeNode* root, int depth);

#endif