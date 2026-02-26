%option noinput nounput
%option noyywrap
%option reentrant
%option bison-bridge

%{
#include "lib/ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>

#include "parser.tab.h"

typedef struct {
    char *val;
    int len;
    int total;
} ScanString;

static ScanString scanstring;

static void resizeString(bool init, int appendLen, yyscan_t yyscanner);
static void addstring(bool init, char *s, int l, yyscan_t yyscanner);
static void addchar(bool init, char c, yyscan_t yyscanner);
static enum yytokentype checkKeyword(yyscan_t yyscanner);
static bool parseUnicode(char *s, int l, void *escontext, yyscan_t yyscanner);
%}

/* ---- Muster ---- */
ESC     \\["\\/bfnrt]|\\u[0-9a-fA-F]{4}|\\u\{[0-9a-fA-F]{1,6}\}
DQSTR   \"(({ESC})|[^\"\\])*\" 
INT     [0-9]+
NUMBER  -?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?
NAME    [a-zA-Z_][a-zA-Z0-9_]*


%%
"$"             { return DOLLAR; }
"@"             { return AT; }
".."            { return DOTDOT; }
"."             { return DOT; }
"*"             { return STAR; }
"["             { return LBRACK; }
"]"             { return RBRACK; }
"("             { return LPAREN; }
")"             { return RPAREN; }
","             { return COMMA; }
":"             { return COLON; }
"?"             { return QUESTION; }

"=="            { return EQ; }
"!="            { return NE; }
"<="            { return LE; }
">="            { return GE; }
"<"             { return LT; }
">"             { return GT; }
"&&"            { return AND; }
"||"            { return OR; }


{DQSTR} {   /* Strings "..." werden unescaped in scanstring.val geschrieben */
    addchar(true, '\0', yyscanner);           
    if (!parseUnicode(yytext, yyleng, NULL, yyscanner))
        return 0;                              
    yylval_param->str = scanstring.val;       
    return STRING;
}


{INT} {     /* Ganzzahliger Index: INT */
    addstring(true, yytext, yyleng, yyscanner);
    addchar(false, '\0', yyscanner);
    yylval_param->str = scanstring.val;
    return INT;
}


{NUMBER} {  /* Sonstige Zahl (negativ/dezimal/exponent): NUMBER */
    addstring(true, yytext, yyleng, yyscanner);
    addchar(false, '\0', yyscanner);
    yylval_param->str = scanstring.val;
    return NUMBER;
}


{NAME} {    /* Namen – KEINE Keyword-Map auf TRUE/FALSE/NULLVAL */
    addstring(true, yytext, yyleng, yyscanner);
    addchar(false, '\0', yyscanner);
    yylval_param->str = scanstring.val;
    return checkKeyword(yyscanner); 
}


[ \t\n\r]+    { /* Whitespace ignorieren */ }


. {     /* Fallback: unbekanntes Zeichen → Parserfehler provozieren */
    fprintf(stderr, "Unbekanntes Zeichen: '%s'\n", yytext);
    return *yytext;
}

%%

/* ---- Helpers ---- */
static void resizeString(bool init, int appendLen, yyscan_t yyscanner) {
    (void)yyscanner;    // <-  aktuell unbenutzt
    if (init) {
        scanstring.total = 32 + appendLen;
        scanstring.val = (char*)malloc(scanstring.total);
        scanstring.len = 0;
    } else if (scanstring.len + appendLen >= scanstring.total) {
        scanstring.total = (scanstring.len + appendLen) * 2;
        scanstring.val = (char*)realloc(scanstring.val, scanstring.total);
    }
}

static void addstring(bool init, char *s, int l, yyscan_t yyscanner) {
    resizeString(init, l + 1, yyscanner);
    memcpy(scanstring.val + scanstring.len, s, l);
    scanstring.len += l;
}

static void addchar(bool init, char c, yyscan_t yyscanner) {
    resizeString(init, 1, yyscanner);
    scanstring.val[scanstring.len++] = c;
    if (c == '\0') scanstring.len--;
}

/* KEINE Keyword-Erkennung → immer NAME zurückgeben. 
   (So bleiben .true, .false, .null gültige Feldnamen.) */
static enum yytokentype checkKeyword(yyscan_t yyscanner) {
    (void)yyscanner;
    return NAME;
    /* Wenn man später Filter aktiviert:
       if (!strcmp(scanstring.val,"true")) return TRUE; ... */
}

/* Sehr einfache Unescape-/Unicode-Handhabung (ASCII-only Fallback) */
static bool parseUnicode(char *s, int l, void *escontext, yyscan_t yyscanner) {
    (void)escontext;    // <-  aktuell unbenutzt
    (void)yyscanner;    // <-  aktuell unbenutzt
    int i = 1; 
    while (i < l - 1) { 
        if (s[i] == '\\') {
            i++;
            if (s[i] == 'u') {
                i++;
                int code = 0;
                if (s[i] == '{') {
                    i++;
                    while (s[i] != '}' && isxdigit((unsigned char)s[i])) {
                        code = code * 16 + (isdigit((unsigned char)s[i]) ? s[i]-'0' : tolower((unsigned char)s[i])-'a'+10);
                        i++;
                    }
                    if (s[i] == '}') i++;
                } else {
                    for (int j = 0; j < 4 && i < l; j++) {
                        code = code * 16 + (isdigit((unsigned char)s[i]) ? s[i]-'0' : tolower((unsigned char)s[i])-'a'+10);
                        i++;
                    }
                }
                addchar(false, (code < 128 ? code : '?'), yyscanner); 
            } else {            
                addchar(false, s[i++], yyscanner);
            }
        } else {
            addchar(false, s[i++], yyscanner);
        }
    }
    addchar(false, '\0', yyscanner);
    return true;
}