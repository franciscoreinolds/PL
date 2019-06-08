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

(PROGRAMA)									{
												printf("Program\n");
												return Prog;
											}

(%languages)								{
												printf("Trans\n");
												//return TRANS;
											}

(%baselang)									{
												//printf("Base\n");
												return BASE;
											}	

(%inv)										{
												printf("Inverse\n");
												//return INV;
											}

[^ |\n]+									{	
												//printf("Word: %s\n",yytext);
												yylval.string = strdup(yytext);
												return WORD;
											}

.|\n 										{
												//printf("Oh hi mark\n");
											}
%%
	/*
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
	*/