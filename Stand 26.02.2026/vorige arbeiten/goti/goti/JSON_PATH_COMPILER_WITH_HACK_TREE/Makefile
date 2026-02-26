all: compiler

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: scanner.l
	flex scanner.l

compiler: parser.tab.c lex.yy.c tree.c compiler.c main.c
	gcc -Wall -g -o compiler parser.tab.c lex.yy.c tree.c compiler.c main.c -lfl

clean:
	rm -f lex.yy.c parser.tab.c parser.tab.h compiler
