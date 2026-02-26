#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <getopt.h>
#include <unistd.h> // isatty

#include "parser.tab.h"
#include "lib/query_yottadb.h"
#include "lib/ast.h"

// ---- Bison/Flex Prototypen ----
typedef void *yyscan_t;
int yylex_init(yyscan_t *);
int yylex_destroy(yyscan_t);
int yyparse(yyscan_t scanner, ASTNode **result);
typedef struct yy_buffer_state *YY_BUFFER_STATE;
YY_BUFFER_STATE yy_scan_string(const char *, yyscan_t);
void yy_delete_buffer(YY_BUFFER_STATE, yyscan_t);

// Baut aus dem AST eine YDB-Referenz wie ^root("a",1,"b"); setzt *unsupported=1 bei unbekannten Knoten.
int build_ydb_ref(const ASTNode *ast, const char *root_global,
                  char *out, size_t outsz, int *unsupported);

// Führt die YDB-Leseabfrage aus (oder simuliert sie) und liefert found=0/1.
int ydb_get(const char *ref, char *out, size_t outsz, int *found);

// ---- Exit-Codes ----
enum
{
    EX_OK = 0,
    EX_USAGE = 1,
    EX_PARSE = 2,
    EX_UNSUPPORTED = 3,
    EX_NOTFOUND = 4,
    EX_YDB = 5
};

// ---- Quiet-Wrapper für stderr (nur um yyparse herum) ----
static int quiet_stderr_begin(bool quiet, int *saved_fd, FILE **devnull)
{
    if (!quiet)
    {
        *saved_fd = -1;
        *devnull = NULL;
        return 0;
    }
    fflush(stderr);
    *saved_fd = dup(fileno(stderr));
    if (*saved_fd < 0)
        return -1;
    *devnull = fopen("/dev/null", "w");
    if (!*devnull)
        return -1;
    if (dup2(fileno(*devnull), fileno(stderr)) < 0)
        return -1;
    return 0;
}

static void quiet_stderr_end(bool quiet, int saved_fd, FILE *devnull)
{
    if (!quiet)
        return;
    fflush(stderr);
    if (saved_fd >= 0)
    {
        dup2(saved_fd, fileno(stderr));
        close(saved_fd);
    }
    if (devnull)
        fclose(devnull);
}

static void print_help(const char *prog)
{
    fprintf(stdout,
            "\nAufruf: %s [OPTIONS] <JSONPath>\n"
            "       echo '<JSONPath>' | %s [OPTIONS]\n\n"
            "Optionen:\n"
            "  -g, --root[=NAME]   Root-Global setzen; ohne NAME aktuelles Root ausgeben\n"
            "  -a, --ast           AST anzeigen\n"
            "  -r, --ref           YottaDB-Referenz anzeigen\n"
            "  -q, --quiet         Nur den Wert ausgeben (kein Prompt/Meta)\n"
            "  -h, --help          Hilfe\n\n"
            "Beispiele:\n"
            "  %s -g ^store -ar '$.book[0].title'\n"
            "  echo '$.bicycle.price' | %s -q\n",
            prog, prog, prog, prog);
}

static int run_one(const char *expr, const char *root_global,
                   bool opt_ast, bool opt_ref, bool opt_quiet)
{
    // 1) Scannen & Parsen
    yyscan_t scanner;
    if (yylex_init(&scanner))
    {
        if (!opt_quiet)
            fprintf(stderr, "Fehler: Scanner-Init fehlgeschlagen.\n");
        return EX_PARSE;
    }

    YY_BUFFER_STATE buf = yy_scan_string(expr, scanner);
    if (!buf)
    {
        if (!opt_quiet)
            fprintf(stderr, "Fehler: Eingabe-Buffer fehlgeschlagen.\n");
        yylex_destroy(scanner);
        return EX_PARSE;
    }

    ASTNode *ast = NULL;

    int saved_fd;
    FILE *devnull = NULL;
    quiet_stderr_begin(opt_quiet, &saved_fd, &devnull);
    int prc = yyparse(scanner, &ast);
    quiet_stderr_end(opt_quiet, saved_fd, devnull);

    yy_delete_buffer(buf, scanner);
    yylex_destroy(scanner);

    // Nur Exit-Code setzen; Parser/Lexer haben bereits eine präzisere Meldung ausgegeben.
    if (prc != 0 || !ast)
    {
        free_ast(ast);
        return EX_PARSE;
    }

    if (opt_ast && !opt_quiet)
    {
        printf("> Ast-Ausgabe:\n");
        print_ast(ast, 0);
    }

    // 2) AST → YDB-Referenz (mit Root)
    char ydbref[1024] = {0};
    int unsupported = 0;

    // Root normalisieren: führendes '^' (falls vorhanden) entfernen
    const char *root = (root_global && *root_global) ? root_global : "store";
    char rootbuf[256];
    if (root[0] == '^')
    {
        snprintf(rootbuf, sizeof rootbuf, "%.*s", (int)sizeof(rootbuf) - 1, root + 1);
        root = rootbuf;
    }

    // Falls nach dem Entfernen von '^' nichts übrig bleibt, auf Default gehen
    if (!*root)
        root = "store";

    if (build_ydb_ref(ast, root, ydbref, sizeof ydbref, &unsupported) != 0)
    {
        if (!opt_quiet)
            fprintf(stderr, "Fehler beim Bauen der YDB-Referenz.\n");
        free_ast(ast);
        return EX_YDB;
    }
    if (unsupported)
    {
        if (!opt_quiet)
            fprintf(stderr, "Fehler: Nicht unterstützte Syntax im Ausdruck.\n");
        free_ast(ast);
        return EX_UNSUPPORTED;
    }

    // Referenz-Anzeige: immer genau ein '^'
    if (opt_ref && !opt_quiet)
    {
        printf("> YottaDB-Abfrage (Global ^%s):\n[YDB] Referenz: %s\n", root, ydbref);
    }

    // 3) YDB lesen
    char value[2048] = {0};
    int found = 1;
    int yrc = ydb_get(ydbref, value, sizeof value, &found);
    if (yrc != 0)
    {
        if (!opt_quiet)
        {
            fprintf(stderr, "YottaDB-Fehler (%d).\n", yrc);
            if (yrc == -3)
                fprintf(stderr, "   Hinweis: Kein Output von docker exec. Läuft der Container '%s'?\n",
                        getenv("YDB_CONTAINER") ? getenv("YDB_CONTAINER") : "ydb");
            if (yrc == -6 && value[0])
                fprintf(stderr, "   Backend: %s\n", value);
        }
        free_ast(ast);
        return EX_YDB;
    }
    if (!found)
    {
        if (!opt_quiet)
            fprintf(stderr, "Fehler: Pfad nicht gefunden.\n");
        free_ast(ast);
        return EX_NOTFOUND;
    }

    // 4) nur der Wert auf STDOUT (damit Pipes/Tests sauber sind)
    printf("%s\n", value);

    free_ast(ast);
    return EX_OK;
}

int main(int argc, char **argv)
{
    const char *root_global = "store"; // Default-Root
    bool opt_ast = false, opt_ref = false, opt_quiet = false, opt_show_root = false;

    static struct option long_opts[] = {
        {"root", optional_argument, 0, 'g'},
        {"ast", no_argument, 0, 'a'},
        {"ref", no_argument, 0, 'r'},
        {"quiet", no_argument, 0, 'q'},
        {"help", no_argument, 0, 'h'},
        {0, 0, 0, 0}};
    int c;
    while ((c = getopt_long(argc, argv, "g::arqh", long_opts, NULL)) != -1)
    {
        switch (c)
        {
        case 'g':
            if (optarg && *optarg)
            {
                root_global = optarg;
            }
            else
            {
                // -g ohne angehängtes Arg: schaue auf das nächste argv
                if (optind < argc)
                {
                    const char *next = argv[optind];
                    // Wenn 'next' kein weiteres -Flag ist und nicht wie JSONPath beginnt, nimm es als Root
                    if (next[0] != '-' && next[0] != '$')
                    {
                        root_global = next;
                        optind++; // dieses argv als Root "verbrauchen"
                    }
                    else
                    {
                        // wirklich kein Root-Arg → aktuelles Root ausgeben
                        opt_show_root = true;
                    }
                }
                else
                {
                    opt_show_root = true;
                }
            }
            break;
        case 'a':
            opt_ast = true;
            break;
        case 'r':
            opt_ref = true;
            break;
        case 'q':
            opt_quiet = true;
            break;
        case 'h':
            print_help(argv[0]);
            return EX_OK;
        default:
            print_help(argv[0]);
            return EX_USAGE;
        }
    }

    // Ein einzelnes Argument → direkt ausführen
    if (optind < argc)
    {
        return run_one(argv[optind], root_global, opt_ast, opt_ref, opt_quiet);
    }

    // Nur -g ohne Ausdruck: Global ausgeben und beenden
    if (opt_show_root && optind >= argc)
    {
        const char *rin = (root_global && *root_global) ? root_global : "store";
        if (*rin == '^')
            rin++;
        char disp[258];
        snprintf(disp, sizeof disp, "^%.*s", 255, rin);
        printf("%s\n", disp);
        return EX_OK;
    }

    // Sonst: STDIN lesen; bei TTY einen Prompt anzeigen
    const bool interactive = isatty(STDIN_FILENO);
    if (interactive && !opt_quiet)
    {
        printf("Gib einen JSONPath-Ausdruck ein (oder 'exit'):\n> ");
        fflush(stdout);
    }

    char line[4096];
    while (fgets(line, sizeof line, stdin))
    {
        size_t n = strlen(line);
        while (n && (line[n - 1] == '\n' || line[n - 1] == '\r'))
            line[--n] = '\0';
        if (n == 0)
        {
            if (interactive && !opt_quiet)
            {
                printf("> ");
                fflush(stdout);
            }
            continue;
        }
        if (!strcmp(line, "exit"))
            break;

        (void)run_one(line, root_global, opt_ast, opt_ref, opt_quiet);

        if (interactive && !opt_quiet)
        {
            printf("> ");
            fflush(stdout);
        }
    }
    return EX_OK;
}
