#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

ASTNode *make_node(ASTNodeType type, ASTNode *left, ASTNode *right, const char *value)
{
    ASTNode *node = malloc(sizeof(ASTNode));
    if (!node)
    {
        fprintf(stderr, "Fehler: Konnte Speicher für ASTNode nicht allokieren\n");
        exit(1);
    }
    node->type = type;
    node->left = left;
    node->right = right;
    node->value = value ? strdup(value) : NULL;
    return node;
}

void print_ast(ASTNode *node, int indent)
{
    if (!node)
        return;

    // Einrückung
    for (int i = 0; i < indent; i++)
        printf("  ");

    // Knoten-Typ ausgeben
    switch (node->type)
    {
    case AST_EQ:
        printf("EQ\n");
        break;
    case AST_NE:
        printf("NE\n");
        break;
    case AST_LT:
        printf("LT\n");
        break;
    case AST_LE:
        printf("LE\n");
        break;
    case AST_GT:
        printf("GT\n");
        break;
    case AST_GE:
        printf("GE\n");
        break;
    case AST_AND:
        printf("AND\n");
        break;
    case AST_OR:
        printf("OR\n");
        break;
    case AST_LITERAL:
        printf("LITERAL: %s\n", node->value ? node->value : "<null>");
        break;
    case AST_IDENTIFIER:
        printf("IDENTIFIER: %s\n", node->value ? node->value : "<null>");
        break;
    case AST_PATH:
        printf("PATH\n");
        break;
    case AST_FILTER:
        printf("FILTER\n");
        break;
    case AST_UNION:
        printf("UNION\n");
        break;
    case AST_RECURSIVE:
        printf("RECURSIVE\n");
        break;
    case AST_STAR:
        printf("STAR\n");
        break;
    case AST_SLICE:
        printf("SLICE\n");
        break;
    case AST_SLICE3:
        printf("SLICE3 (step: %s)\n", node->value ? node->value : "<null>");
        break;
    default:
        printf("UNKNOWN\n");
        break;
    }

    // Rekursiv Kinder anzeigen
    print_ast(node->left, indent + 1);
    print_ast(node->right, indent + 1);
}

void free_ast(ASTNode *node)
{
    if (!node)
        return;

    free_ast(node->left);
    free_ast(node->right);
    if (node->value)
        free(node->value);
    free(node);
}
