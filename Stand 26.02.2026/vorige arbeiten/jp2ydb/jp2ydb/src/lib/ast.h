#ifndef AST_H
#define AST_H

#include <stddef.h>

/**
 * Typen von AST-Knoten, die in der Teilmenge von JSONPath auftreten können.
 */
typedef enum
{
    AST_EQ,         /**< Vergleich: Gleichheit (==) */
    AST_NE,         /**< Vergleich: Ungleich (!=) */
    AST_LT,         /**< Vergleich: Kleiner (<) */
    AST_LE,         /**< Vergleich: Kleiner-gleich (<=) */
    AST_GT,         /**< Vergleich: Größer (>) */
    AST_GE,         /**< Vergleich: Größer-gleich (>=) */
    AST_AND,        /**< Boolesches UND (&&) */
    AST_OR,         /**< Boolesches ODER (||) */
    AST_LITERAL,    /**< Literalwert (z. B. "10" oder "name") */
    AST_IDENTIFIER, /**< Bezeichner (z. B. $, book, color) */
    AST_PATH,       /**< Pfadverkettung */
    AST_FILTER,     /**< Filter-Ausdruck (?()) */
    AST_UNION,      /**< Union ([a,b]) */
    AST_RECURSIVE,  /**< Rekursiver Deszent (..) */
    AST_STAR,       /**< Wildcard (* oder .*) */
    AST_SLICE,      /**< Slice [a:b] */
    AST_SLICE3      /**< Slice [a:b:c] */
    // Erweiterbar mit weiteren Knotentypen
} ASTNodeType;

/**
 * Struktur für einen AST-Knoten.
 *
 * Jeder Knoten enthält:
 *  - Typ (Operator / Literal / Identifier / Pfad etc.)
 *  - optionale Kindknoten (left / right)
 *  - optionalen Wert (z. B. Stringliteral "price" oder Index "0")
 */
typedef struct ASTNode
{
    ASTNodeType type;      /**< Typ des AST-Knotens */
    struct ASTNode *left;  /**< Linker Kindknoten (oder NULL) */
    struct ASTNode *right; /**< Rechter Kindknoten (oder NULL) */
    char *value;           /**< Optionaler Wert (kann NULL sein) */
} ASTNode;

/**
 * Erzeuge einen neuen AST-Knoten.
 *
 * @param type   Knotentyp
 * @param left   Linker Kindknoten (kann NULL sein)
 * @param right  Rechter Kindknoten (kann NULL sein)
 * @param value  Optionaler Stringwert (wird kopiert, kann NULL sein)
 * @return       Zeiger auf neuen Knoten (muss mit free_ast() freigegeben werden)
 */
ASTNode *make_node(ASTNodeType type, ASTNode *left, ASTNode *right, const char *value);

/**
 * Gib den AST rekursiv auf stdout aus (Debugzwecke).
 *
 * @param node    AST-Knoten (Wurzel oder Teilbaum)
 * @param indent  Einrückungstiefe (Start: 0)
 */
void print_ast(ASTNode *node, int indent);

/**
 * Gib Speicher für einen AST (rekursiv) frei.
 *
 * @param node  AST-Knoten (Wurzel oder Teilbaum)
 */
void free_ast(ASTNode *node);

#endif /* AST_H */
