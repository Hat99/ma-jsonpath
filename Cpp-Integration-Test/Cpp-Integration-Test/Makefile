CPP=clang++

all:
	bison -d jsonpath.y -o jsonpath.tab.cpp

	flex --header-file=lex.yy.h jsonpath.l
		
	${CPP} -c lex.yy.c -o lex.yy.o
	${CPP} -c jsonpath.tab.cpp -o jsonpath.tab.o
	${CPP} -c main.cpp -o main.o

	${CPP} lex.yy.o jsonpath.tab.o main.o -o exec

clean:
	rm -f lex.yy.c lex.yy.h jsonpath.tab.cpp jsonpath.tab.hpp lex.yy.o jsonpath.tab.o main.o exec *.tex *.pdf *.log *.aux
