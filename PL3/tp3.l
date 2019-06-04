%{
#include "y.tab.h"	
%}
%option noyywrap
%%

\%language .* 				{return TARGET_LANGS;}
\%baselang .*				{return BASELANG;}
\%inv .*
"("							{return INICIO_LISTA;} //Inicio da lista de Notas
")"							{return FIM_LISTA;} //Fim da lista de Notas
[,]							{return yytext[0];} // nao usar espacos nem mudancas de linha como separador na gramatica
[a-zA-Z]+[a-zA-Z0-9 ]+		{yylval.string= strdup(yytext); return ID;} //Numero do aluno
\'[^\']*\'					{return NOME;} //
[0-9]+						{return NOTA;}
.|\n 						{;}
%%