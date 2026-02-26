
CPP=g++
include=../../include

all: syntaxtree-2 syntaxtree-3 syntaxtree-4
	echo "1+2*3"|./syntaxtree-2 > 2.tex
	pdflatex 2
	echo "1+2*3"|./syntaxtree-3 > 3.tex
	pdflatex 3
	echo "1+2*3"|./syntaxtree-4 > 4.tex
	pdflatex 4
	
syntaxtree-2: syntaxtree-2.y lex.yy.c
	bison syntaxtree-2.y -o y.tab.cpp
	${CPP} y.tab.cpp -I$(include) -o syntaxtree-2

syntaxtree-3: syntaxtree-3.y lex.yy.c
	bison syntaxtree-3.y -o y.tab.cpp
	${CPP} y.tab.cpp -I$(include) -o syntaxtree-3

syntaxtree-4: syntaxtree-4.y lex.yy.c
	bison syntaxtree-4.y -o y.tab.cpp
	${CPP} y.tab.cpp -I$(include) -o syntaxtree-4

lex.yy.c: scanner.l
	lex scanner.l


clean:
	rm -f texput.* y.* lex.* 2.* 3.* 4.*

clean-all: clean
	rm -f syntaxtree-1 syntaxtree-2 syntaxtree-3 syntaxtree-4
