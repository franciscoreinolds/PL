%{
#include <stdio.h>
#include <stdlib.h>
int yylex();
int concs = 0;
void yyerror(char *s);
%}
%union {char* string;}
%token Program_Beginning
%token LANGUAGES
%token <string> ID
%%

Program : LANGUAGES TRANS_LANGS BASE_LANG INV CONCEPTS

TRANS_LANGS : ID {printf("TRANS_LANGS: %s FIM\n",$1);}
			;

BASE_LANG 	: ID {printf("BASE_LANG: %s FIM\n",$1);}
		  	;

INV : ID {printf("INV: %s\n",$1);}
	;

CONCEPTS : ID {printf("CONCEPTS: %s\n",$1);}

	/*
	LANGUAGES : TRANS_LANGS BASELANG INVERSE

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

	Concept : BASE_TERM

	BASE_TERM : {printf("base_term:%s\n",$0);}
		  ;
	*/
%%

#include "lex.yy.c"

void yyerror(char* s){
	printf("Erro sintático %s\n",s);
}
/*
int main(){
	yyparse();
	return(0);
}
*/
