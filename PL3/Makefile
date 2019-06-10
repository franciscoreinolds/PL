CC = gcc

prog: y.tab.c lex.yy.c
	gcc y.tab.c -g `pkg-config --cflags --libs glib-2.0` -w -o prog
	mkdir html

lex.yy.c: prog.l
	flex prog.l

y.tab.c: prog.y
	yacc -d -v prog.y

clean:
	rm lex.yy.c y.tab.* prog y.output
	rm -r html