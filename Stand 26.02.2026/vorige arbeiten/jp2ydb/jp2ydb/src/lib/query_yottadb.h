#ifndef QUERY_YOTTADB_H
#define QUERY_YOTTADB_H

#include <stddef.h>
#include "ast.h"

/**
 * Baue eine YottaDB-Referenz aus dem AST.
 *
 * Beispiel: $.bicycle.color → ^store("bicycle","color")
 *
 * @param ast          AST-Knotenbaum
 * @param root_global  Name des Root-Globals (z. B. "store")
 * @param out          Ausgabe-Puffer für die Referenz
 * @param outsz        Größe des Ausgabe-Puffers
 * @param unsupported  Optional: 1, falls der AST nicht unterstützt wird
 * @return 0 bei Erfolg, -1 bei Fehler
 */
int build_ydb_ref(const ASTNode *ast, const char *root_global,
                  char *out, size_t outsz, int *unsupported);

/**
 * Hole einen Wert aus YottaDB (über Docker + JPBRIDGE).
 *
 * @param ref    YottaDB-Referenz (z. B. ^store("bicycle","color"))
 * @param out    Ausgabe-Puffer für Wert (falls gefunden)
 * @param outsz  Größe des Ausgabe-Puffers
 * @param found  Optional: wird auf 1 gesetzt, falls Key existiert
 * @return 0 = OK, <0 = Fehlercode
 */
int ydb_get(const char *ref, char *out, size_t outsz, int *found);

#endif /* QUERY_YOTTADB_H */
