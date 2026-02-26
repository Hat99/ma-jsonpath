# Compiler / Werkzeuge
CC     = gcc
FLEX   = flex
BISON  = bison

# Quell-Dateien
LEX_SRC     = scanner.l
YACC_SRC    = parser.y
MAIN_SRC    = main.c
TEST_SRC    = scanner_test.c
AST_SRC     = lib/ast.c
YDB_SRC = lib/query_yottadb.c

# Generierte Dateien
LEX_OUT     = lex.yy.c
YACC_OUT    = parser.tab.c
YACC_HEADER = parser.tab.h

# Executables
EXEC       = jp2ydb

# Compiler-Flags
CFLAGS = -Wall

# Alle Objektdateien / Quellmodule
SRC        = $(LEX_OUT) $(YACC_OUT) $(MAIN_SRC) $(AST_SRC)
TEST_DEPS  = $(LEX_OUT) $(TEST_SRC)

# Targets
all: $(EXEC)

$(EXEC): $(LEX_OUT) $(YACC_OUT) $(YACC_HEADER) $(MAIN_SRC) $(AST_SRC) $(YDB_SRC)
	$(CC) $(CFLAGS) -o $@ $^ -lfl


$(YACC_OUT) $(YACC_HEADER): $(YACC_SRC)
	$(BISON) -d $<

$(LEX_OUT): $(LEX_SRC) $(YACC_HEADER)
	$(FLEX) -o $@ $<


clean:
	rm -f $(LEX_OUT) $(YACC_OUT) $(YACC_HEADER) $(EXEC)
