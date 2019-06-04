%{
#include <stdio.h>
int yylex();
int alunoA;
int contaA;
int contaN;
void yyerror(char *s);
%}
%union {char* string;}
%token TURMA_INICIO
%token INICIO_LISTA FIM_LISTA
%token <string >ID 
%token <string> NOME
%token <string> NOTA
%type <string > CodAl 
%%

	/*
	Uma turma tem um início, um ID e Alunos.
	Ele começa a processar a turma e dentro disso, processa alunos, etc...
	Por isso metemos o printf final aqui, já que isto é a última coisa a ser processada
	*/


conceito : CONCEITO TRANSLATIONS CONNECTIONS

turma : TURMA_INICIO CodTurma Alunos {printf("Existem: %d alunos na turma.\n",contaA);}
	  ;																			  

CodTurma : ID
         ;

Alunos: Aluno {contaA =1;}
	  | Alunos Aluno {contaA++;}
	  ;

	/*
	Um aluno tem id, nome e uma lista de notas.
	OU
	Um aluno tem id e uma lista de notas.
	*/

Aluno: CodAl NOME LNotas {printf("O aluno %s tem %d notas\n",$1,contaN);}
	 | CodAl LNotas 	  {printf("O aluno %d tem %d notas\n",contaA+1,contaN);}
	 ;

CodAl : ID {$$=$1;}
      ;

	/*
	Uma lista de notas tem um início, NOTAS e fim.
	*/

LNotas: INICIO_LISTA Notas FIM_LISTA

	/*
	Uma NOTAS é uma nota.
	OU
	Uma NOTAS é uma NOTA com mais NOTAS.
	*/

Notas: NOTA {contaN = 1;}
	 | Notas ',' NOTA {contaN++;}
	 ;
%%

#include "lex.yy.c"

void yyerror(char* s){
	printf("Erro sintático %s\n",s);
}

int main(){
	yyparse();
	return(0);
}
