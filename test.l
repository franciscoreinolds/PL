%{
#include <gmodule.h>
#include <glib.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include "free.h"
#define gp_to_int(p) ((gint)  (glong) (p))
#define gi_to_ptr(i) ((gpointer) (glong) (i))

int article = 0;

int lim = 0;

FILE* fd;

char *id       = "";

char *title    = "";

char *author   = "";

GHashTable* hash;

GArray *tags;

char *category = "";

char *text     = "";

%}

letter [a-zA-Z0-9]

dig [0-9]

%x NEWS

%x TAGS

%x ID

%x CATEGORY

%x TITLE

%x DATE

%%

"<pub>"			 				{	article++;
									if(article <= lim){
										BEGIN NEWS; 
										printf("Artigo nº%d\n",article); 
										fprintf(fd,"%s%d%s", "Artigo nº",article,"\n");
									}
								}	//Começa a Start Condition NEWS

<NEWS>"</pub>" 					{
									if(article <= lim){
										BEGIN INITIAL; 
										printf("Fim do artigo nº%d\n\n",article);
										fprintf(fd,"%s%d%s", "Fim do artigo nº",article,"\n\n");								
										g_array_free(tags, TRUE);
									}
								}	//Começa a Start Condition INITIAL

<NEWS>"#TAG: "					{
									if(article <= lim){ 
										BEGIN TAGS;
								    	tags = g_array_new(FALSE, FALSE, sizeof(GString *));
								    	fprintf(fd,"%s","Tags:");
									}
								}	//Começa a Start Condition TAGS

<TAGS>"tag:{"[^}]*"}"			{
									if(article <= lim){ 
										yytext[yyleng-1]='\0';
										fprintf(fd," %s",yytext+5);
										char* tag = strdup(yytext+5);
										GString *s = g_string_new(yytext+5);
										g_array_append_val(tags,s);
									  	free(tag);
							  		}
								}	//Imprime as tags individuais

<TAGS>"#ID:{post-"[^ ]+			{
									if(article <= lim){ 
										BEGIN ID;
										printf("id: %s", yytext+5);
									}
								}	//Começa a Start Condition ID

<ID>[^}]*"}"					{
								BEGIN CATEGORY;
								} //Imprime info relacionada com ID e começa a Start Condition CATEGORY

<CATEGORY>^(.)*					{
									if(article <= lim){ 
										printf("Categoria: %s\n", yytext); 
										char* toWrite = malloc(strlen(yytext) + strlen("\nCategoria: "));
										strcat(toWrite,strdup("\nCategoria: "));
										strcat(toWrite,strdup(yytext));
										strcat(toWrite,"\0");
										fprintf(fd,"%s",toWrite);
										free(toWrite);
										BEGIN TITLE;
									}
								} //Imprime a categoria da notícia e começa a Start Condition TITLE

<TITLE>^(.)*					{
									if(article <= lim){ 
										char* toW = malloc((strlen(yytext) + strlen("\nTitulo: ")));
										toW[0] = '\0';
										strcat(toW,strdup("\nTitulo: "));
										strcat(toW,strdup(yytext));
										strcat(toW,"\0");
										fprintf(fd,"%s",toW);
										free(toW);
										printf("Title: %s", yytext);
										BEGIN DATE;
									}
								}	//Imprime o título e começa a Start Condition Date

<DATE>[━|(PARTILHE VIA:)]*		{;} //Ignora a barra gigante e o "PARTILHE VIA" antes da data

<DATE>"#DATE: ["[^]]*"]"		{
								//printf("Cena da date: %s", yytext);
								BEGIN NEWS; 
								}	//Imprime a data da notícia, autor e começa a Start Condition NEWS

<NEWS>"Etiquetas".* 			{;}	//Ignora a parte das Etiquetas da Notícia

<NEWS>\[.*] 					{;} //Ignora as [aaa16] que se encontram antes do corpo das notícias

<NEWS>.|\n						{
									if(article <= lim){ 
										fprintf(fd,"%s",yytext);
										//printf("%s",yytext);
									}
								}
%%

int yywrap(){
 return 1;
}


int main(int argc, char *argv[]){

	fd = fopen("normalized.txt","w");

	yyin=fopen(argv[1],"r");

	lim = atoi(argv[2]);

 	yylex();

    /*
    hash = g_hash_table_new_full (g_str_hash, g_str_equal,free_data,free_data);

    char* tag = "Droga";
    gint* gkey = g_new(gint,1);
    gkey = gi_to_ptr(5);
    g_hash_table_insert (hash, tag, gkey);

    char* tag2 = "Droga";
    void* res = g_hash_table_lookup(hash, tag2);
    int lol = gp_to_int(res);

    GList* lista = g_hash_table_get_keys (hash);
    
    GList *l;
    for (l = lista; l != NULL; l = l->next){
        char* s = l->data;
        printf("Elem:%s\n", s);
    }
    */

    fclose(fd);

	return 0;
}
