prog: lex.yy.c
	gcc lex.yy.c aux.c -g `pkg-config --cflags --libs glib-2.0` -o prog
	mkdir html
	mkdir tags
	rm lex.yy.c

lex.yy.c: test.l
	lex test.l

clean:
	rm prog normalized.txt html/*.html *.html
	rm -r html tags