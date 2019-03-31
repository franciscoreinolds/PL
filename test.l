%{
#include <glib.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include "free.h"
#include <sys/stat.h>

#define gp_to_int(p) ((gint)  (glong) (p))
#define gi_to_ptr(i) ((gpointer) (glong) (i))

int article = 0;	// Contador do número do artigo atual
int lim = 0;		// Número de artigos a processar
int nTags = 0; 		// Número de tags de um post
int flag = 0;		// Flag que indica se o GPtrArray pode ser freed ou não
int repeated = 0;	// Flag para identificar posts repetidos

FILE* 		fd = NULL;				// Apontador para o ficheiro que contém os artigos normalizados
FILE*	    html = NULL;			// Apontador para o ficheiro html do artigo atual
FILE*	    html1 = NULL;			// Apontador para o ficheiro html das tags
char		*fileName = "";			// String que guard o nome do ficheiro a ser criado, i.e. "post-1643"
char		*fileType = ".html";	// String que guarda a extensão dos ficheiro a serem criados
char 		*title    = "";			// String que guarda o título do artigo atual
char 		*category = "";			// String que guarda a categoria do artigo atual
char		*directory = "";		// String que guarda a diretoria onde são colocados os ficheiros

GHashTable	*hash;					// Estrutura utilizada para monitorizar o número de ocorrências de cada tag
GTree		*idPosts;				// Estrutura utilizada para monitorizar que posts já foram processados
GPtrArray 	*tags;					// Estrutura utilizada para monitorizar que tags são utilizadas em cada post
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
	if(article <= lim){		//Verifica se o artigo ainda se encontra dentro do número máximo de artigos a processar
		fprintf(fd,"%s%d%s", "Artigo nº",article,"\n");
		html = fopen("lixo.html", "w");
		BEGIN NEWS;
	}
}	//ínicio de cada artigo, inicia a start condition "NEWS"

<NEWS>"</pub>" 					{
	if(article <= lim){		//Verifica se o artigo ainda se encontra dentro do número máximo de artigos a processar
		fprintf(html, "\t</text>\n</pub>");
		fclose(html);	//Fecha o ficheiro html do artigo atual
		fprintf(fd,"%s%d%s", "Fim do artigo nº",article,"\n\n");
		if(nTags > 0) {		//Dá free ao array que guarda as tags de um post
			g_ptr_array_free(tags,TRUE);
			flag = 0;
		}
		BEGIN INITIAL;
		nTags = 0;	//Reset ao contador de tags e á flag de artigos repetido, pois vai-se iniciar um artigo novo
		repeated = 0;
	}
}	//Fim de cada artigo, retorna á start condition á inicial

<NEWS>"#TAG: "					{
	if(article <= lim){		//Verifica se o artigo ainda se encontra dentro do número máximo de artigos a processar
    	if (!flag) {
    		tags = g_ptr_array_new_with_free_func(free);	//Cria o array para armazenar as tags
    		flag = 1;
    	}
    	fprintf(fd,"%s","Tags:");	//Imprime no ficheiro normalizado
	}
}	//Aciona a flag que indica que o artigo possui tags

<NEWS>"tag:{"[^}]*"}"			{
	if(article <= lim){ 	//Verifica se o artigo ainda se encontra dentro do número máximo de artigos a processar
		yytext[yyleng-1]='\0';
		fprintf(fd," %s",yytext+5);
		if (strchr(yytext+5, '/')) removeChar(yytext+5,'/');
		g_ptr_array_add(tags,strdup(yytext+5));		//Adiciona a tag ao array
		nTags++;			//Incrementa o contador de tags
	}
}	//Coloca as Tags no array e incrementa o contador de tags

<NEWS>"#ID:{post-"[^ ]+			{
	if(article <= lim){		//Verifica se o artigo ainda se encontra dentro do número máximo de artigos a processar
		if(g_tree_lookup(idPosts,yytext+5)) repeated = 1;
		if(!repeated){
			g_tree_insert(idPosts,strdup(yytext+5),strdup(yytext+5));
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
			strcat(dir,"\0");

			directory = strdup(dir);

			fclose(html);
			html = fopen(dir,"w"); //ficheiro .html que contem um post
			fprintf(html, "<pub id=\"%s\">\n", fileName);

			if(nTags) g_ptr_array_foreach(tags,(GFunc) addsTags,hash);

			free(dir);
			free(fileName);
		}
	}
}	//Começa a Start Condition ID, Cria o ficheiro HTML para o artigo atual e o respetivo path.

<ID>[^}]*"}"					{
	BEGIN CATEGORY;
} //Imprime info relacionada com ID e começa a Start Condition CATEGORY

<CATEGORY>^(.)*					{
	if(article <= lim && !repeated){	//Verifica se o artigo ainda se encontra dentro do número máximo de artigos a processar e se não se trata de um artigo repetido
		char* toWrite = malloc((strlen(yytext) + strlen("\nCategoria: ")+1)*sizeof(char));
		category = strdup(yytext);
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
	if(article <= lim && !repeated){	//Verifica se o artigo ainda se encontra dentro do número máximo de artigos a processar e se não se trata de um artigo repetido
		fprintf(html,"<title>%s</title>\n",yytext);
		char* toW = malloc((strlen(yytext) + strlen("\nTitulo: ")+1)*sizeof(char));
		title=strdup(yytext);
		toW[0] = '\0';
		strcat(toW,"\nTitulo: ");
		strcat(toW,yytext);
		strcat(toW,"\0");
		fprintf(fd,"%s",toW);
		free(toW);
		BEGIN DATE;

	}
}	//Imprime o título e começa a Start Condition Date

<DATE>[━|(PARTILHE VIA:)]*		{;} //Ignora a barra gigante e o "PARTILHE VIA" antes da data

<DATE>[^#]		{;} //Ignora a barra gigante e o "PARTILHE VIA" antes da data

<DATE>"#DATE: ["[^]]*"]".*		{
	if (article <= lim && !repeated) {	//Verifica se o artigo ainda se encontra dentro do número máximo de artigos a processar e se não se trata de um artigo repetido
		yytext[yyleng-1]='\0';
		fprintf(html, "\t<author_data>%s</author_date>\n", yytext+14); //imprime a data
		fprintf(html, "\t<tags>\n\t\t");
		for(int i = 0; i < nTags; i++){
			gchar* tag = (gchar*) g_ptr_array_index(tags,i);
			fprintf(html, "<tag>%s</tag> ", tag);
			char* htmlfile = malloc(sizeof(char)*(strlen(tag) + strlen("tags/") + strlen(".html")+1));
			strcpy(htmlfile,"tags/");
			strcat(htmlfile,tag);
			strcat(htmlfile,fileType);
			strcat(htmlfile,"\0");
			
			FILE* tagfile = fopen(htmlfile,"a");
			char* fulldir = realpath(directory,NULL);
			fprintf(tagfile,"<li>\n<a  href=\"%s\">%s</a>\n</li>",fulldir,title);
			fclose(tagfile);
			free(fulldir);
			free(htmlfile);
		}
		fprintf(html, "\n\t</tags>\n");
		fprintf(html, "\t<category>%s</category>\n\t<text>\n", category);
		free(category);
		category = "";
		free(directory);
		directory = "";
		free(title);
		title="";
	}
	BEGIN NEWS;
}	//Imprime a data da notícia, autor e começa a Start Condition NEWS, Imprime as tags no ficheiro HTMl correspondente

<NEWS>"Etiquetas".* 			{;}	//Ignora a parte das Etiquetas da Notícia

<NEWS>\[.*] 					{;} //Ignora as [aaa16] que se encontram antes do corpo das notícias

<NEWS>.|\n						{
	if(article <= lim && !repeated){	//Verifica se o artigo ainda se encontra dentro do número máximo de artigos a processar e se não se trata de um artigo repetido
		fprintf(fd,"%s", yytext);
		fprintf(html,"%s", yytext);
	}
}

<*>.|\n 							{;}
%%

int yywrap(){
 return 1;
}


int main(int argc, char *argv[]){

	fd = fopen("normalized.txt","w"); // Abre o ficheiro onde vão ser inseridos os artigos normalizados

	yyin=fopen(argv[1],"r"); // O nome do ficheiro .txt a processar

	lim = atoi(argv[2]); // O número de artigos a ser processados

	hash = g_hash_table_new_full(g_str_hash,g_str_equal,free,NULL);

	idPosts = g_tree_new_full((GCompareDataFunc)g_ascii_strcasecmp,NULL,free,free);

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
		gchar* key = (gchar*) key1;
		char* htmlfile = malloc(sizeof(char)*(strlen(key) + strlen("tags/") + strlen(".html")+1));
		strcpy(htmlfile,"tags/");
		strcat(htmlfile,key);
		strcat(htmlfile,fileType);
		strcat(htmlfile,"\0");
		char* fulldir = realpath(htmlfile,NULL);
		fprintf(html1, "<li>Tag: <a  href=\"%s\">%s</a> -> Ocorrências %d </li>\n\n",fulldir,key,gp_to_int(value1));
		free(htmlfile);
		free(fulldir);
	}

	g_hash_table_remove_all(hash);

	g_hash_table_destroy(hash);

	g_tree_destroy(idPosts);

	fclose(html1);

	unlink("lixo.html");

  	fclose(fd);

	return 0;
}
