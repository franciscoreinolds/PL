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
int nTags = 0; // Representa o número de tags de um post, para saber quantas tem te imprimir no ficheiro
FILE* 		fd = NULL;
FILE*	    html = NULL;
char		*fileName = "";
char		*fileType = ".html";
char 		*id       = "";
char 		*title    = "";
char 		*author   = "";
char 		*category = "";
GString 	*text;
GHashTable	*hash;
GArray 		*tags;

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

"<pub>"			 				{	
	article++;
	if(article <= lim){
		printf("Artigo nº%d\n",article);
		printf("hello :D"); 
		fprintf(fd,"%s%d%s", "Artigo nº",article,"\n");
		BEGIN NEWS;
		html = fopen("lixo.html", "w");
	}
}	//Começa a Start Condition NEWS

<NEWS>"</pub>" 					{
	if(article <= lim){
		fprintf(html, "\t</text>\n</pub>");
		fclose(html); 
		printf("Fim do artigo nº%d\n\n",article);
		fprintf(fd,"%s%d%s", "Fim do artigo nº",article,"\n\n");								
		if(nTags == 0) g_array_free(tags, FALSE);
		else g_array_free(tags, TRUE);
		BEGIN INITIAL;
	}
}	//Começa a Start Condition INITIAL

<NEWS>"#TAG: "					{
	if(article <= lim){
    	tags = g_array_new(FALSE, FALSE, sizeof(GString *));
    	fprintf(fd,"%s","Tags:");
	}
}	//Começa a Start Condition TAGS

<NEWS>"tag:{"[^}]*"}"			{
	if(article <= lim){
		yytext[yyleng-1]='\0';
		fprintf(fd," %s",yytext+5);
		//char *tag = strdup(yytext+5);
		GString *s = g_string_new(yytext+5);
		g_array_append_val(tags,s);
		//free(tag);
		nTags++;
	}
}	//Coloca as Tags num array

<NEWS>"#ID:{post-"[^ ]+			{
	if(article <= lim){ 
		BEGIN ID;
		GString *tag;
		printf("id: %s", yytext+5);
		char *fileName = yytext+5;
		strcat(fileName, fileType);
		html = fopen(fileName,"w"); //ficheiro .html que contem um post
		fprintf(html, "<pub id=\"%s\">\n", yytext+5);
	}
}	//Começa a Start Condition ID, Imprime as tags no ficheiro HTMl correspondente

<ID>[^}]*"}"					{
	BEGIN CATEGORY;
} //Imprime info relacionada com ID e começa a Start Condition CATEGORY

<CATEGORY>^(.)*					{
	if(article <= lim){ 
		printf("Categoria: %s\n", yytext); 
		category = strdup(yytext);
		char* toWrite = malloc(strlen(yytext) + strlen("\nCategoria: "));
		toWrite[0] = '\0';
		strcat(toWrite,"\nCategoria: ");
		strcat(toWrite,strdup(yytext));
		strcat(toWrite,"\0");
		fprintf(fd,"%s",toWrite);
		free(toWrite);
		BEGIN TITLE;
	}
} //Imprime a categoria da notícia e começa a Start Condition TITLE

<TITLE>^(.)*					{
	if(article <= lim){ 
		fprintf(html,"<title>%s</title>\n",yytext);
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

<DATE>"#DATE: ["[^]]*"]".*		{
	printf("Cena da date: %s", yytext+14);
	yytext[yyleng-1]='\0';
	fprintf(html, "\t<author_data>%s</author_date>\n", yytext+14); //imprime a data
	fprintf(html, "\t<tags>\n\t\t");
	for(int i = 0; i < nTags; i++){
			GString *tag = g_array_index(tags,GString *, i);
			fprintf(html, "<tag>%s</tag> ", tag->str);
	}
	fprintf(html, "\n\t</tags>\n");
	fprintf(html, "\t<category>%s</category>\n\t<text>\n", category);
	nTags = 0;
	BEGIN NEWS;

}	//Imprime a data da notícia, autor e começa a Start Condition NEWS

<NEWS>"Etiquetas".* 			{;}	//Ignora a parte das Etiquetas da Notícia

<NEWS>\[.*] 					{;} //Ignora as [aaa16] que se encontram antes do corpo das notícias

<NEWS>.|\n						{
	if(article <= lim){ 
		fprintf(fd,"%s", yytext);
		printf("%s",yytext);
		fprintf(html,"%s", yytext);
	}
}

.|\n 							{;}
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
        //printf("Elem:%s\n", s);
    }
    */

	unlink("lixo.html");
    fclose(fd);

	return 0;
}
