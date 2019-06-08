%{
#include "y.tab.h"
#include <glib.h>

char* until_space (char* text) {
	char* res = strdup(text);
	int i = 0;
	while(res[i]!=' ') i++;
	res[i] = '\0';
	return res;
}

char* baselang;
GTree* languages;
GHashTable* inverses;

%}

word [a-zA-Z0-9áéíóúàèìòùãẽĩõũâêîôûäïöüåøñçæ\'ó]+
space [a-zA-Z0-9 ,()+\*-/:+áéíóúàèìòùãẽĩõũâêîôûäïöüåøñçæ\'ó]+

%option noyywrap
%%

(%language).*							{	
											printf("Language: %s\n",yytext);
											char* aux = strtok(yytext," ");
											aux = strtok(NULL," ");
											while(aux){
												printf("aux: %s\n",aux);
												g_tree_insert(languages,strdup(aux),strdup(aux));
												aux = strtok(NULL," ");
											}
											yylval.gtree = languages;
											return TRANS;
										}
(%baselang).*							{
											printf("BaseLang: %s\n",yytext);
											char* aux = strtok(yytext," ");
											aux = strtok(NULL," ");
											printf("aux: %s\n",aux);
											baselang = strdup(aux);
											yylval.string = strdup(aux);
											return BASE;
										}
(%inv).*								{
											char* aux = strtok(yytext," ");
											aux = strtok(NULL," ");
											struct info estrutura;
											estrutura.rel1 = strdup(aux);
											printf("Rel1: %s\n",aux);
											aux = strtok(NULL," ");
											printf("Rel2: %s\n",aux);
											estrutura.rel2 = strdup(aux);
											yylval.info = estrutura;
											g_hash_table_insert(inverses,strdup(estrutura->rel1),strdup(estrutura->rel2);
											g_hash_table_insert(inverses,strdup(estrutura->rel2),strdup(estrutura->rel1);
											return INV;
										}
\#.*									{
											printf("Comment: %s\n",yytext);
										}
[^ ]+\ (.)+						{
											//printf("YYtext: %s\n",yytext);
											char* res = until_space(yytext);
											if (g_tree_lookup(languages,res)) {
												printf("Found language: %s\n",res);
											}
											else if (g_hash_table_lookup(inverses,res)){
												printf("Found relation: %s\n",res);
											}
											else {
												printf("Found term: %s\n",yytext);
											}
											/*
											printf("res: %s\n",res);
											char* aux = strtok(yytext," ");
											printf("aux: %s\n",aux);
											aux = strtok(NULL," ");
											printf("aux: %s\n",aux);
											aux = strtok(aux,", ");
											while (aux){
												printf("aux comma: %s\n",aux);
												aux = strtok(NULL,", ");
											}
											*/
										}	
\n\n									{
											printf("New Concept\n");
											return Concept_End;
										}
.|\n 									{;}

%%

int printEntry(char* key, char* value) {
  printf("key: %s\tvalue: %s\n", key, value);
  return 0;
}

int main(){ 
	languages =  g_tree_new((GCompareFunc)strcmp);
	inverses = g_hash_table_new_full(g_str_hash,g_str_equal,free,NULL);
	yylex();
	g_tree_foreach(languages, (GTraverseFunc) printEntry, NULL);
	if (g_tree_lookup(languages,"EN")) printf("Found EN\n");
	g_tree_destroy(languages);

	GHashTableIter iter;
	gpointer key1;
	gpointer value1;
	g_hash_table_iter_init (&iter, inverses);
	while (g_hash_table_iter_next (&iter, &key1, &value1)) {
		gchar* key = (gchar*) key1;
		gchar* value = (gchar*) value1;
		printf("Pair: %s <> %s \n",key,value);
	}
  return 0;
}
