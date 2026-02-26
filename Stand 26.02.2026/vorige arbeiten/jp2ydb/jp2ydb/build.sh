#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-release}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT="$ROOT/build"
BIN="$ROOT/bin"
APP="jp2ydb"           

SRC_DIR="$ROOT"
[[ -f "$ROOT/src/main.c" ]] && SRC_DIR="$ROOT/src"

CC="${CC:-}"
[[ -z "${CC}" ]] && command -v clang >/dev/null 2>&1 && CC=clang || true
[[ -z "${CC}" ]] && command -v gcc   >/dev/null 2>&1 && CC=gcc   || true
[[ -z "${CC}" ]] && CC=cc

need(){ command -v "$1" >/dev/null 2>&1 || { echo "Fehlt: $1"; exit 2; }; }

if [[ "$MODE" == "clean" ]]; then
  rm -rf "$OUT" "$BIN"
  echo "Clean OK."
  exit 0
fi

need "$CC"; need bison; need flex
mkdir -p "$OUT" "$BIN"

COMMON_CFLAGS="-std=c11 -Wall -Wextra -D_POSIX_C_SOURCE=200809L -I$ROOT/src -I$ROOT/src/lib -I$OUT"
if [[ "$MODE" == "debug" ]]; then
  CFLAGS="$COMMON_CFLAGS -O0 -g -DDEBUG"
else
  CFLAGS="$COMMON_CFLAGS -O2 -DNDEBUG"
fi

# flex-Lib: Linux -lfl, macOS häufig -ll
LIBS="-lfl"
if [[ "$(uname -s)" == "Darwin" ]]; then
  LIBS="-ll"
fi

echo "==> Mode: $MODE"
echo "==> CC:   $CC"

# --- Generierte Parser-/Lexer-Dateien ---
echo "[1/6] bison..."
bison -d -o "$OUT/parser.tab.c" "$SRC_DIR/parser.y"

echo "[2/6] flex..."
flex -o "$OUT/lex.yy.c" "$SRC_DIR/scanner.l"

# --- Kompilieren ---
echo "[3/6] compile ast.c"
$CC $CFLAGS -c "$ROOT/src/lib/ast.c" -o "$OUT/ast.o"

echo "[4/6] compile query_yottadb.c"
$CC $CFLAGS -c "$ROOT/src/lib/query_yottadb.c" -o "$OUT/query_yottadb.o"

echo "[5/6] compile parser + lexer"
$CC $CFLAGS -c "$OUT/parser.tab.c" -o "$OUT/parser.tab.o"
$CC $CFLAGS -c "$OUT/lex.yy.c"     -o "$OUT/lex.yy.o"

echo "[6/6] compile main.c"
$CC $CFLAGS -c "$ROOT/src/main.c" -o "$OUT/main.o"

# --- Link ---
echo "Link..."
$CC  "$OUT/main.o" "$OUT/ast.o" "$OUT/query_yottadb.o" "$OUT/parser.tab.o" "$OUT/lex.yy.o" \
    -o "$BIN/$APP" $LIBS

echo "Fertig: $BIN/$APP"
echo "Beispiel: JP_BRIDGE_FILE=src/lib/JPBRIDGE.m YDB_CONTAINER=ydb $BIN/$APP -ar '\$.bicycle.color'"

