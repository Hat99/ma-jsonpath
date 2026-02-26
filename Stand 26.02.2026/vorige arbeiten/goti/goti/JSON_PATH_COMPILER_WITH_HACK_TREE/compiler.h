#ifndef COMPILER_H
#define COMPILER_H

#include <stdio.h>
#include "tree.h"

// Compiles the given syntax tree to a YottoDB-compatible output
void compileToYottoDB(TreeNode* node, FILE* output);

#endif
