CC = gcc

tp3: y.tab.c lex.yy.c
	gcc y.tab.c -g `pkg-config --cflags --libs glib-2.0` -o tp3

lex.yy.c: tp3.l
	flex tp3.l

y.tab.c: tp3.y
	yacc -d -v tp3.y

clean:
	rm lex.yy.c y.tab.* tp3