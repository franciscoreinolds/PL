%{
#include <gmodule.h>
#include <glib.h>
#include <stdlib.h>
#define gp_to_int(p) ((gint)  (glong) (p))
#define gi_to_ptr(i) ((gpointer) (glong) (i))
int article=0;
%}
letter [a-zA-Z0-9]
%x NEWS
%x TAGS
%x ID
%x CATEGORY
%x TITLE
%x DATE
%%
"<pub>"			 				{BEGIN NEWS; printf("Artigo nº%d\n",article+1);}	//Começa a Start Condition NEWS
<NEWS>"</pub>" 					{BEGIN INITIAL;printf("Fim do artigo nº%d\n\n",++article);}	//Começa a Start Condition INITIAL
<NEWS>"#TAG: "					{BEGIN TAGS;}	//Começa a Start Condition TAGS
<TAGS>"tag:{"[^}]*"}"			{yytext[yyleng-1]='\0'; printf("yytext: %s", yytext+5);}	//Imprime as tags individuais
<TAGS>"#ID:"					{BEGIN ID;}	//Começa a Start Condition ID
<ID>"{"[^}]*"}"					{printf("id: %sFIM",yytext); BEGIN CATEGORY;} //Imprime info relacionada com ID e começa a Start Condition CATEGORY
<CATEGORY>^(.)*					{printf("Categoria: %s", yytext); BEGIN TITLE;} //Imprime a categoria da notícia e começa a Start Condition TITLE
<TITLE>^(.)*					{printf("Title: %s", yytext);BEGIN DATE;}	//Imprime o título e começa a Start Condition Date
<DATE>[━|(PARTILHE VIA:)]*		{;} //Ignora a barra gigante e o "PARTILHE VIA" antes da data
<DATE>"#DATE: ["[^]]*"]"		{printf("Cena da date: %s", yytext);BEGIN NEWS;}	//Imprime a data da notícia, autor e começa a Start Condition NEWS 
<NEWS>"Etiquetas".* 			{;} //Ignora a parte das Etiquetas da Notícia
<NEWS>\[.*] 					{;} //Ignora as [aaa16] que se encontram antes do corpo das notícias
<NEWS>[.|\n] 					{printf("%s",yytext);} //Imprime conteúdo da notícia
.|\n {;}
%%

int yywrap(){
 return 1;
}

int main(){
 	yylex();
 	char* ola = "Ola";
 	GHashTable* hash = NULL;
 	
 	gchar* gkey = g_new(gchar,1);
	gkey = (gchar*) ola;
	
	gint* gvalue = g_new(gint,1);

	gvalue = gi_to_ptr(1);
  	
  	hash = g_hash_table_new_full (g_int_hash, g_int_equal,g_free,NULL);
	g_hash_table_insert(hash, gkey, gvalue);

	gint* res = (g_hash_table_lookup(hash, gkey));

	int lol = gp_to_int(res);

	printf("The item is '%d'\n", lol);
	return 0;
}