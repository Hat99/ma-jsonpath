all:
	flex --header-file=lex.yy.h jsonpath.l

	bison -d jsonpath.y

	gcc -c lex.yy.c -o lex.yy.o
	gcc -c jsonpath.tab.c -o jsonpath.tab.o
	g++ -c main.cpp -o main.o

	g++ lex.yy.o jsonpath.tab.o main.o -o exec

clean:
	rm -f lex.yy.c lex.yy.h jsonpath.tab.c jsonpath.tab.h lex.yy.o jsonpath.tab.o main.o exec
