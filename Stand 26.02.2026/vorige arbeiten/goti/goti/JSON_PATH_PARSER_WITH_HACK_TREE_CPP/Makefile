
CPP=clang++
include=./include

all: parser
	echo "$$.store.athours[5:10].books[*]"|./parser > ./output/op.tex
	
parser: parser.y lex.yy.c
	bison parser.y -o y.tab.cpp
	${CPP} y.tab.cpp -I$(include) -o parser

lex.yy.c: scanner.l
	lex scanner.l

clean:
	rm -f texput.* y.* lex.* parser