#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <unistd.h>
#include <errno.h>

#include "query_yottadb.h"

/* ---------- Helpers ---------- */

static void buf_cat(char *buf, size_t size, const char *s)
{
    if (!buf || !s || size == 0)
        return;
    size_t bl = strlen(buf), sl = strlen(s);
    if (bl >= size - 1)
        return;
    if (sl > size - bl - 1)
        sl = size - bl - 1;
    memcpy(buf + bl, s, sl);
    buf[bl + sl] = '\0';
}

/* -- HELPER: trailing ',' -> ')', sonst ')' anhängen -- */
static void finalize_ref(char *ref, size_t refsz)
{
    if (!ref || !*ref)
        return;
    size_t len = strlen(ref);
    if (len == 0)
        return;
    if (ref[len - 1] == ',')
    {
        ref[len - 1] = '\0';
        buf_cat(ref, refsz, ")");
    }
    else if (ref[len - 1] != ')')
    {
        buf_cat(ref, refsz, ")");
    }
}

/* ersetzt " -> \" für die Shell (Bash) */
static void shell_escape_dquotes(const char *in, char *out, size_t outsz)
{
    size_t j = 0;
    for (size_t i = 0; in && in[i] && j + 2 < outsz; ++i)
    {
        if (in[i] == '"')
        {
            if (j + 2 >= outsz)
                break;
            out[j++] = '\\';
            out[j++] = '"';
        }
        else
        {
            out[j++] = in[i];
        }
    }
    out[j] = '\0';
}

/* JSON-Escape für Schlüssel/Werte */
static void json_escape(const char *in, char *out, size_t outsz)
{
    size_t j = 0;
    for (size_t i = 0; in && in[i] && j + 2 < outsz; ++i)
    {
        unsigned char c = (unsigned char)in[i];
        switch (c)
        {
        case '\"':
            if (j + 2 < outsz)
            {
                out[j++] = '\\';
                out[j++] = '\"';
            }
            break;
        case '\\':
            if (j + 2 < outsz)
            {
                out[j++] = '\\';
                out[j++] = '\\';
            }
            break;
        case '\b':
            if (j + 2 < outsz)
            {
                out[j++] = '\\';
                out[j++] = 'b';
            }
            break;
        case '\f':
            if (j + 2 < outsz)
            {
                out[j++] = '\\';
                out[j++] = 'f';
            }
            break;
        case '\n':
            if (j + 2 < outsz)
            {
                out[j++] = '\\';
                out[j++] = 'n';
            }
            break;
        case '\r':
            if (j + 2 < outsz)
            {
                out[j++] = '\\';
                out[j++] = 'r';
            }
            break;
        case '\t':
            if (j + 2 < outsz)
            {
                out[j++] = '\\';
                out[j++] = 't';
            }
            break;
        default:
            if (c < 0x20)
            {
                if (j + 6 < outsz)
                    j += snprintf(out + j, outsz - j, "\\u%04x", c);
            }
            else
            {
                out[j++] = c;
            }
        }
    }
    out[j] = '\0';
}

/* in M müssen doppelte Anführungszeichen verdoppelt werden
   (wird hier aktuell nicht benötigt, bleibt aber verfügbar) */
static void m_escape(const char *in, char *out, size_t outsz)
{
    if (!out || outsz == 0)
        return;
    size_t j = 0;
    if (!in)
    {
        out[0] = '\0';
        return;
    }
    for (size_t i = 0; in[i] && j + 2 < outsz; ++i)
    {
        if (in[i] == '"')
        {
            out[j++] = '"';
            out[j++] = '"';
        }
        else
        {
            out[j++] = in[i];
        }
    }
    out[j] = '\0';
}

/* ---------- AST → YDB-Referenz ---------- */

static void walk_ast(const ASTNode *n, char *out, size_t outsz, int *need_comma, int *unsupported)
{
    if (!n)
        return;

    switch (n->type)
    {
    case AST_PATH:
        walk_ast(n->left, out, outsz, need_comma, unsupported);
        walk_ast(n->right, out, outsz, need_comma, unsupported);
        return;

    case AST_IDENTIFIER:
        if (n->value && strcmp(n->value, "$") == 0)
            return; /* Wurzel */
        if (*need_comma)
            buf_cat(out, outsz, ",");
        {
            char esc[512];
            m_escape(n->value ? n->value : "", esc, sizeof esc);
            buf_cat(out, outsz, "\"");
            buf_cat(out, outsz, esc);
            buf_cat(out, outsz, "\"");
        }
        *need_comma = 1;
        return;

    case AST_LITERAL:
        if (*need_comma)
            buf_cat(out, outsz, ",");
        {
            long idx = strtol(n->value ? n->value : "0", NULL, 10);
            char num[64];
            snprintf(num, sizeof num, "%ld", idx + 1); /* 0-basiert -> 1-basiert */
            buf_cat(out, outsz, num);
        }
        *need_comma = 1;
        return;

    default:
        if (unsupported)
            *unsupported = 1;
        return;
    }
}

int build_ydb_ref(const ASTNode *ast, const char *root_global,
                  char *out, size_t outsz, int *unsupported)
{
    if (unsupported)
        *unsupported = 0;
    if (!out || outsz == 0 || !ast || !root_global || !*root_global)
        return -1;

    out[0] = '\0';
    buf_cat(out, outsz, "^");
    buf_cat(out, outsz, root_global);
    buf_cat(out, outsz, "(");

    int need_comma = 0;
    walk_ast(ast, out, outsz, &need_comma, unsupported);

    finalize_ref(out, outsz);
    return 0;
}

/* ---------- YDB aus Docker lesen ---------- */
/* --- Bridge-Routine-Implementierung --- */

static int ensure_bridge_in_container(const char *container)
{
    char checkcmd[512];
    snprintf(checkcmd, sizeof checkcmd, "docker exec %s test -f /tmp/JPBRIDGE.o", container);
    int ret = system(checkcmd);
    if (ret == 0)
        return 0; /* vorhanden */

    char cmd[1024];
    snprintf(cmd, sizeof cmd,
             "docker cp ./src/JPBRIDGE.m %s:/tmp/ && "
             "docker exec %s bash -lc '"
             "source /opt/yottadb/current/ydb_env_set >/dev/null 2>&1 && "
             "export ydb_routines=\"/tmp $ydb_routines\" && "
             "mumps /tmp/JPBRIDGE.m"
             "'",
             container, container);

    return system(cmd);
}

static int docker_ydb_get_routine(const char *ref_in, char *out, size_t outsz, int *found)
{
    if (found)
        *found = 0;
    if (out && outsz)
        out[0] = '\0';
    if (!ref_in || !*ref_in)
        return -1;

    // Refereenz kopieren und anpassen
    char ref[1024];
    snprintf(ref, sizeof ref, "%s", ref_in);
    finalize_ref(ref, sizeof ref);

    const char *container = getenv("YDB_CONTAINER");
    if (!container || !*container)
        container = "ydb";

    if (ensure_bridge_in_container(container) != 0)
    {
        if (out && outsz)
            snprintf(out, outsz, "failed to install JPBRIDGE");
        return -7;
    }

    /* Referenz für Bash: "..." um das Ganze, innen " -> \" */
    char ref_esc[3072];
    shell_escape_dquotes(ref, ref_esc, sizeof ref_esc);

    char ref_arg[4096];
    snprintf(ref_arg, sizeof ref_arg, "\"%s\"", ref_esc);

    char cmd[8192];
    snprintf(cmd, sizeof cmd,
             "docker exec -i %s bash -lc '"
             "source /opt/yottadb/current/ydb_env_set >/dev/null 2>&1 || exit 99; "
             "export ydb_routines=\"/tmp $ydb_routines\"; "
             "ydb -run JPBRIDGE %s 2>&1"
             "'",
             container, ref_arg);

    if (getenv("JP_DEBUG"))
        fprintf(stderr, "[cmd] %s\n", cmd);

    FILE *pp = popen(cmd, "r");
    if (!pp)
        return -2;

    int debug = getenv("JP_DEBUG") ? 1 : 0;
    char line[4096];

    int have_d = 0;
    long dflag = 0;

    /* top-level value (bei d=1 oder d=11) */
    char top_value[4096] = {0};
    int have_top_value = 0;

    /* Kinder als JSON-Objekt bauen */
    char objbuf[8192];
    size_t objlen = 0;
    int have_children = 0;
    char last_key_raw[2048] = {0};

    while (fgets(line, sizeof line, pp))
    {
        for (int i = (int)strlen(line) - 1; i >= 0 && (line[i] == '\n' || line[i] == '\r'); --i)
            line[i] = '\0';

        if (debug)
            fprintf(stderr, "[ydb] %s\n", line);

        if (!strncmp(line, "JP:D:", 5))
        {
            const char *p = line + 5;
            while (*p == ' ' || *p == '\t')
                ++p;
            dflag = strtol(p, NULL, 10);
            have_d = 1;
            if (debug)
                fprintf(stderr, "[marker] JP:D = %ld\n", dflag);
        }
        // else if (!strncmp(line, "JP:K:", 5))
        //{
        //     /* Kind-Schlüssel (volle ^global(...)-Ref aus Routine) */
        //     const char *p = line + 5;
        //     while (*p == ' ' || *p == '\t')
        //         ++p;
        //     snprintf(last_key_raw, sizeof last_key_raw, "%s", p);
        // }
        else if (!strncmp(line, "JP:V:", 5))
        {
            const char *p = line + 5;
            while (*p == ' ' || *p == '\t')
                ++p;

            if (last_key_raw[0])
            {
                /* Value zu einem vorhergehenden Key -> ins Objekt */
                char kesc[4096], vesc[4096];
                json_escape(last_key_raw, kesc, sizeof kesc);
                json_escape(p, vesc, sizeof vesc);

                if (!have_children)
                {
                    objlen += snprintf(objbuf + objlen, sizeof(objbuf) - objlen, "{");
                    have_children = 1;
                }
                else
                {
                    objlen += snprintf(objbuf + objlen, sizeof(objbuf) - objlen, ",");
                }

                objlen += snprintf(objbuf + objlen, sizeof(objbuf) - objlen,
                                   "\"%s\":\"%s\"", kesc, vesc);
                last_key_raw[0] = '\0';
            }
            else
            {
                /* Top-Level Wert */
                snprintf(top_value, sizeof top_value, "%s", p);
                have_top_value = 1;
            }

            if (debug)
                fprintf(stderr, "[marker] JP:V = %s\n", p);
        }
    }
    pclose(pp);

    if (!have_d)
    {
        if (out && outsz)
            snprintf(out, outsz, "no JP:D marker");
        return -6;
    }

    if (have_children)
    {
        objlen += snprintf(objbuf + objlen, sizeof(objbuf) - objlen, "}");
    }

    /* Ausgabe priorisieren:
       - d=1: top_value
       - d=10: nur Kinder -> objbuf (oder {} als Fallback)
       - d=11: kombiniertes JSON {"$value":"...","$children":{...}} (oder nur $value) */
    if ((dflag == 1) && have_top_value && !have_children)
    {
        if (out && outsz)
            snprintf(out, outsz, "%s", top_value);
    }
    else if (dflag == 10)
    {
        if (out && outsz)
        {
            if (have_children)
                snprintf(out, outsz, "%s", objbuf);
            else
                snprintf(out, outsz, "{}"); // <— Fallback statt leerer Ausgabe
        }
    }
    else if (dflag == 11)
    {
        if (have_children)
        {
            char vesc[4096];
            json_escape(top_value, vesc, sizeof vesc);
            if (out && outsz)
                snprintf(out, outsz, "{\"$value\":\"%s\",\"$children\":%s}", vesc, objbuf);
        }
        else
        {
            // Wert vorhanden, aber keine Kinderzeilen gesehen
            if (out && outsz)
                snprintf(out, outsz, "%s", have_top_value ? top_value : "");
        }
    }
    else
    {
        // d=0 oder untypisch: leere Ausgabe
        if (out && outsz)
            out[0] = '\0';
    }

    if (found)
        *found = (dflag != 0);
    return 0;
}

/* öffentliche API – ruft die Routine-Variante */
int ydb_get(const char *ref, char *out, size_t outsz, int *found)
{
    return docker_ydb_get_routine(ref, out, outsz, found);
    // API varianten hinzufügen
}
