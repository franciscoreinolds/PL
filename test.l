%{
#include <gmodule.h>
#include <glib.h>
#include <stdlib.h>
#define gp_to_int(p) ((gint)  (glong) (p))
#define gi_to_ptr(i) ((gpointer) (glong) (i))
int article    =0;
char *id       = "";
char *title    = "";
char *author   = "";
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
"<pub>"			 				{BEGIN NEWS; printf("Artigo nº%d\n",article+1);}	//Começa a Start Condition NEWS

<NEWS>"</pub>" 					{BEGIN INITIAL; printf("Fim do artigo nº%d\n\n",++article);
								g_array_free(tags, TRUE);}	//Começa a Start Condition INITIAL

<NEWS>"#TAG: "					{BEGIN TAGS;
							     tags = g_array_new(FALSE, FALSE, sizeof(GString *));}	//Começa a Start Condition TAGS

<TAGS>"tag:{"[^}]*"}"			{yytext[yyleng-1]='\0';
								GString *s = g_string_new(yytext+5);
								g_array_append_val(tags, s);
								GString *p = g_array_index(tags, GString *, 0);
								printf("tag: %s", p->str);}	//Imprime as tags individuais

<TAGS>"#ID:{post-"[^ ]+			{BEGIN ID;
								id = strdup(yytext+5);
								printf("id: %s", yytext);}	//Começa a Start Condition ID

<ID>[^}]*"}"					{BEGIN CATEGORY;} //Imprime info relacionada com ID e começa a Start Condition CATEGORY

<CATEGORY>^(.)*					{printf("Categoria: %s", yytext); BEGIN TITLE;} //Imprime a categoria da notícia e começa a Start Condition TITLE

<TITLE>^(.)*					{printf("Title: %s", yytext);BEGIN DATE;}	//Imprime o título e começa a Start Condition Date

<DATE>[━|(PARTILHE VIA:)]*		{;} //Ignora a barra gigante e o "PARTILHE VIA" antes da data

<DATE>"#DATE: ["[^]]*"]"		{printf("Cena da date: %s", yytext);BEGIN NEWS; printf("The News Have Begun\n");}	//Imprime a data da notícia, autor e começa a Start Condition NEWS

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

    hash = g_hash_table_new_full (g_str_hash, g_str_equal,free_data,free_data);

    char* tag = "Droga";
    gint* gkey = g_new(gint,1);
    gkey = gi_to_ptr(5);
    g_hash_table_insert (hash, tag, gkey);

    char* tag2 = "Droga";
    void* res = g_hash_table_lookup(hash, tag2);
    int lol = gp_to_int(res);
    printf("O resultado de %s: %d\n", tag2, lol);

    GList* lista = g_hash_table_get_keys (hash);

    GList *l;
    for (l = lista; l != NULL; l = l->next){
        char* s = l->data;
        printf("Elem:%s\n", s);
    }

	return 0;
}
