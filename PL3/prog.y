%{
#include <stdio.h>
#include <stdlib.h>
#include <glib.h>
int yylex();
int concs = 0;
void yyerror(char *s); 
%}
%union {char* string;}
%token Prog
%token <string> WORD
%token BASE
%token INV
%token TRANS
%%

Program : Prog Languages

Languages : Languages Lang {printf("Languages Lang\n");}
		  | Lang {printf("Lang\n");}
		  ;

Lang : BaseLang
	 | TransLang
	 | Inverse
	 ;

BaseLang : BASE {printf("BASE\n");}
		 ;

TransLang : TRANS words
		  ;

Inverse : INV words
		;

words : WORD {printf("WORD: %s\n",$1);}
	  | words WORD {printf("words WORD: %s\n",$2);}
	  ;

	/*
	Program : LANGUAGES

	LANGUAGES : Language
			  | LANGUAGES Language
			  ;

	Language : TRANS_LANGS 
			 | BASE_LANG 
			 | INVERSES
			 ;

	langs : lang
	      | lang langs
	      ;

	TRANS_LANGS : translangs langs
				;

	BASE_LANG : baselangs lang
			  ;

	INVERSES : inv langs
			 ;

	TRANS_LANGS : {printf("trans_lang:%s\n",$0);}
				| {printf("trans_langss:%s\n",$0);}
				;

	BASELANG : {printf("base_lang:%s\n",$0);}
			 ;

	INVERSE : {printf("inv1,inv2:%s\n",$0);}
			;

	CONCEPTS : Concept 				{concs++;}
			 | Concept CONCEPTS		{concs++;}
			 ;

	Concept : BASE_TERM EXPRESSIONS Concept_End
			;

	EXPRESSIONS :
				| Expression EXPRESSIONS
				;

	Expression : INV words
			   | LANG words
			   ;

	BASE_TERM : {printf("base_term:%s\n",$0);}
		  	  ;
	*/
%%

#include "lex.yy.c"

	void yyerror(char* s){
	printf("Erro sintático %s\n",s);
}