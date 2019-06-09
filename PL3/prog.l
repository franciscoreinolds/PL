%{
#include "y.tab.h"
#include "info.h"
#include <gmodule.h>
#include <glib.h>

char* until_space (char* text) {
	char* res = strdup(text);
	int i = 0;
	while(res[i]!=' ') i++;
	res[i] = '\0';
	return res;
}

char* after_space (char* text) {
	int i = 0;
	while(text[i]!=' ') i++;
	char* res = malloc(sizeof(char)*(strlen(text)-i));
	res[0] = '\0';
	strncpy(res,text+i+1,strlen(text));
	return res;
}
	
int has_comma (char* text){
	int i = 0;
	while (text[i]!=',' && text[i]!='\0') i++;
	if (text[i]=='\0') return 0;
	else return i;
}

char* baselang;
GTree* languages;
GHashTable* inverses;

int inverses_init = 0;

%}
word [a-zA-Z0-9áéíóúàèìòùãẽĩõũâêîôûäïöüåøñçæ\'ó]+
space [a-zA-Z0-9 ,()+\*-/:+áéíóúàèìòùãẽĩõũâêîôûäïöüåøñçæ\'ó]+
%%

(%language).*				{	
								char* aux = strtok(yytext," ");
								aux = strtok(NULL," ");
								while(aux){
									printf("Language: %s\n",aux);
									g_tree_insert(languages,strdup(aux),strdup(aux));
									aux = strtok(NULL," ");
								}
								yylval.tree = languages;
								return TRANS;
							}
(%baselang).*				{
								yylval.string = strdup(yytext+10);
								return BASE;
							}	
(%inv).*					{
								if (!inverses_init)	{
									inverses = g_hash_table_new_full(g_str_hash,g_str_equal,free,NULL);
									inverses_init = 1;
								}
								char* aux = strtok(yytext," ");
								aux = strtok(NULL," ");
								struct info estrutura;
								estrutura.rel1 = strdup(aux);
								aux = strtok(NULL," ");
								estrutura.rel2 = strdup(aux);
								printf("Estrutura rel1: %s rel2 %s\n",estrutura.rel1,estrutura.rel2);
								yylval.ptr = &estrutura;
								g_hash_table_insert(inverses,strdup(estrutura.rel1),strdup(estrutura.rel2));
								g_hash_table_insert(inverses,strdup(estrutura.rel2),strdup(estrutura.rel1));
								return INV;
							}
[^ \n]+						{
								printf("Termo: %s\n",yytext);
								yylval.string = strdup(yytext); 
								return WORD;
							}												
[^ %\n]+\ (.)+				{
								char* res = until_space(yytext);
								if (g_tree_lookup(languages,res)) {
									char* after = after_space(yytext);
									struct info *estrutura = malloc(sizeof(struct info));
									estrutura->rel1 = strdup(res);
									estrutura->rel2 = strdup(after);
									yylval.ptr = estrutura;
									return TRANSLATION;
								}
								else if (g_hash_table_lookup(inverses,res)){
									printf("Found relation:%s\n",yytext);
									char* after = after_space(yytext);
									printf("After: %s\n",after);
									GList*	aux = NULL;
									int comma = has_comma(after);
									if (comma) {
										char* toTok = strtok(after,", ");
										int it = 0;
										while (toTok){
											aux = g_list_append(aux,strdup(toTok));
											toTok = strtok(NULL,", ");
											it++;
										}
									}									
									else {
										printf("The text: %s does not have commas!\n",after);
										aux = g_list_append(aux,strdup(after));
									}
									struct relation* estrutura = malloc(sizeof(struct relation));
									estrutura->term = strdup(res);
									estrutura->collection = g_list_copy_deep(aux,(GCopyFunc) strdup,NULL);
									yylval.rel = estrutura;
									return RELATION;
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
\n[\n]+						{
								printf("New Concept\n");
								return START_CONCEPT;
							}
.|\n 						{;}
%%

int yywrap(){
	/*
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
	*/
	return 1;
}