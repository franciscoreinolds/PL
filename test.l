%{
#include <glib.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include "free.h"
#include "common.h"
#include "tag.h"
#include "tag.c"
#include "common.c"
#include <sys/stat.h>

#define gp_to_int(p) ((gint)  (glong) (p))
#define gi_to_ptr(i) ((gpointer) (glong) (i))

int article = 0;
int lim = 0;
int nTags = 0; // Representa o número de tags de um post
FILE* 		fd = NULL;
FILE*	    html = NULL;
FILE*	    html1 = NULL;
char		*fileName = "";
char		*fileType = ".html";
char 		*id       = "";
char 		*title    = "";
char 		*author   = "";
char 		*category = "";
char		*dir = NULL;
char 		*temp; // apontador temporário usado para escrever as tags na hash table
GString 	*text;
GHashTable	*hash;
GTree	*idPosts;
GArray *tags;

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
		printf("hello :D\n");
		fprintf(fd,"%s%d%s", "Artigo nº",article,"\n");
		html = fopen("lixo.html", "w");
		BEGIN NEWS;
		printf("news begun\n");
	}
}	//Começa a Start Condition NEWS

<NEWS>"</pub>" 					{
	if(article <= lim){
		fprintf(html, "\t</text>\n</pub>");
		fclose(html);
		printf("Fim do artigo nº%d\n\n",article);
		fprintf(fd,"%s%d%s", "Fim do artigo nº",article,"\n\n");
		if(nTags == 0) {
			//g_array_free(tags, FALSE);
		}
		else g_array_free(tags, TRUE);
		//free(dir);
		BEGIN INITIAL;
		nTags = 0;
	}
}	//Começa a Start Condition INITIAL

<NEWS>"#TAG: "					{
	if(article <= lim){
			printf("Array initialization\n");
    	tags = g_array_new(FALSE, FALSE, sizeof(char*));
    	fprintf(fd,"%s","Tags:");
	}
}	//Começa a Start Condition TAGS

<NEWS>"tag:{"[^}]*"}"			{
	if(article <= lim){
		yytext[yyleng-1]='\0';
		fprintf(fd," %s",yytext+5);
		char* insert = yytext+5;
		g_array_append_val(tags,insert);
		nTags++;

		char* toI = strdup(yytext+5);
		if(!g_hash_table_lookup(hash, toI)){
			g_hash_table_insert (hash, toI, gi_to_ptr(1));
		}
		else {
			gint* res = g_hash_table_lookup(hash,toI);
			int toAdd = gp_to_int(res)+1;
			g_hash_table_steal(hash,toI);
			g_hash_table_insert (hash,toI,gi_to_ptr(toAdd));
		}
	}


}	//Coloca as Tags num array

<NEWS>"#ID:{post-"[^ ]+			{
	if(article <= lim){
		if(!g_tree_lookup(idPosts,yytext+5)){
			g_tree_insert(idPosts,strdup(yytext+5),NULL);
			BEGIN ID;

			char *fileName = malloc((strlen(yytext+5)+strlen(fileType)+1)*sizeof(char));
			fileName[0] = '\0';
			strcat(fileName,yytext+5);
			strcat(fileName, fileType);
			strcat(fileName,"\0");

			char *dir = (char *) malloc((strlen(fileName)+strlen("html/")+1)*sizeof(char));
			dir[0] = '\0';
			strcat(dir, "html/");
			strcat(dir, fileName);

			html = fopen(dir,"w"); //ficheiro .html que contem um post
			fprintf(html, "<pub id=\"%s\">\n", yytext+5);

			free(fileName);
			free(dir);
			free(temp);
		}
	}
}	//Começa a Start Condition ID, Cria o ficheiro HTML para o artigo atual e o respetivo path.

<ID>[^}]*"}"					{
	BEGIN CATEGORY;
} //Imprime info relacionada com ID e começa a Start Condition CATEGORY

<CATEGORY>^(.)*					{
	if(article <= lim){
		printf("Categoria: %s\n", yytext);
		char* toWrite = malloc((strlen(yytext) + strlen("\nCategoria: ")+1)*sizeof(char));
		toWrite[0] = '\0';
		strcat(toWrite,"\nCategoria: ");
		strcat(toWrite,yytext);
		strcat(toWrite,"\0");
		fprintf(fd,"%s",toWrite);
		free(toWrite);
		BEGIN TITLE;
	}
} //Imprime a categoria da notícia e começa a Start Condition TITLE

<TITLE>^(.)*					{
	if(article <= lim){
		fprintf(html,"<title>%s</title>\n",yytext);
		char* toW = malloc((strlen(yytext) + strlen("\nTitulo: ")+1)*sizeof(char));
		toW[0] = '\0';
		strcat(toW,"\nTitulo: ");
		strcat(toW,yytext);
		strcat(toW,"\0");
		fprintf(fd,"%s",toW);
		free(toW);
		printf("Title: %s", yytext);
		BEGIN DATE;

	}
}	//Imprime o título e começa a Start Condition Date

<DATE>[━|(PARTILHE VIA:)]*		{;} //Ignora a barra gigante e o "PARTILHE VIA" antes da data

<DATE>"#DATE: ["[^]]*"]".*		{
	//printf("Cena da date: %s", yytext+14);
	yytext[yyleng-1]='\0';
	fprintf(html, "\t<author_data>%s</author_date>\n", yytext+14); //imprime a data
	fprintf(html, "\t<tags>\n\t\t");
	printf("nTags: %d\n",nTags);
	for(int i = 0; i < nTags; i++){
			printf("str:%s\n",g_array_index(tags, char*, i));
			fprintf(html, "<tag>%s</tag> ", g_array_index(tags, char*, i));
	}
	fprintf(html, "\n\t</tags>\n");
	fprintf(html, "\t<category>%s</category>\n\t<text>\n", category);
	BEGIN NEWS;
	printf("news\n");

}	//Imprime a data da notícia, autor e começa a Start Condition NEWS, Imprime as tags no ficheiro HTMl correspondente

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

	mkdir("./html", 0777);

	fd = fopen("normalized.txt","w");

	yyin=fopen(argv[1],"r");

	lim = atoi(argv[2]);

	hash = g_hash_table_new_full (g_str_hash,g_str_equal,free,NULL);

	idPosts = g_tree_new_full((GCompareDataFunc)g_ascii_strcasecmp,NULL,free,NULL);

 	yylex();

	char *fileName1 = malloc((strlen("lista_tags")+ strlen(fileType)+1)*sizeof(char));
	fileName1[0]='\0';
	strcat(fileName1, "lista_tags");
	strcat(fileName1, fileType);
	html1 = fopen(fileName1,"a");
	free(fileName1);


	GHashTableIter iter;
	gpointer key1;
	gpointer value1;


	g_hash_table_iter_init (&iter, hash);
	while (g_hash_table_iter_next (&iter, &key1, (gpointer) &value1)){
		if(value1!=NULL){
			int lol1 = gp_to_int(value1);
			fprintf(html1, "Elem:%s -> %d\n", (gchar*) key1, lol1);  // esta é linha que dá merda !!!!!!
			printf("Elem:%s -> %d\n", (gchar*) key1, lol1);  // esta é linha que dá merda !!!!!!
		}
	}

	g_hash_table_destroy(hash);

	g_tree_destroy(idPosts);



/*
    GHashTableIter iter;
    int size=g_hash_table_size(hash);
    printf("First size: %d\n", size);


    //uint32_t *val;
    //uint32_t *key_;
	char* key1;
	int value1;

    // My problem is in the following loop
    // it always returns the same and the last key value pair

    g_hash_table_iter_init (&iter, hash);
    while (g_hash_table_iter_next (&iter, (gpointer) &key1, (gpointer) &value1)) printf("key %s ---> %d\n", (char*) key1, gp_to_int(value1));


	GHashTableIter iter;
	char* key1;
	gpointer value1;


		g_hash_table_iter_init (&iter, hash);
		while (g_hash_table_iter_next (&iter, &key1, (gpointer) &value1)){
				if(value1!=NULL){
					int lol1 = gp_to_int(value1);

					if(html1 && key1 && lol1){
						//printf("nº -> %d\n", lol1);
						//printf("tagº -> %s\n", tag);
						fprintf(html1, "Elem:%s -> %d\n", key1,lol1);  // esta é linha que dá merda !!!!!!
					}
					//free(tag);
				}
		}
	//free(fileType);
	//free(id);
	//free(author);
	//free(category);
*/

	fclose(html1);

	unlink("lixo.html");

  	fclose(fd);

	return 0;
}
