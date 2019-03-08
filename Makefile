prog: lex.yy.c
	gcc lex.yy.c `pkg-config --cflags --libs glib-2.0` -o prog
	rm lex.yy.c

lex.yy.c: test.l
	lex test.l

clean:
	rm prog