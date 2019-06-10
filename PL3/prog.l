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

int after_space (char* text) {
	int i = 0;
	while(text[i]!=' ' && text[i]!='\0') i++;
	if (text[i]!='\0') return i;
	else return 0;
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
int languages_init = 0;

%}
word [a-zA-Z0-9áéíóúàèìòùãẽĩõũâêîôûäïöüåøñçæ\'ó]+
space [a-zA-Z0-9 ,()+\*-/:+áéíóúàèìòùãẽĩõũâêîôûäïöüåøñçæ\'ó]+
%%

(%language).*				{	
								char* aux = strtok(yytext," ");
								aux = strtok(NULL," ");
								while(aux){
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
									inverses = g_hash_table_new_full(g_str_hash,g_str_equal,free,free);
									inverses_init = 1;
								}
								char* aux = strtok(yytext," ");
								aux = strtok(NULL," ");
								struct info* estrutura = malloc(sizeof(struct info));
								estrutura->rel1 = aux;
								aux = strtok(NULL," ");
								estrutura->rel2 = aux;
								yylval.ptr = estrutura;
								g_hash_table_insert(inverses,strdup(estrutura->rel1),strdup(estrutura->rel2));
								g_hash_table_insert(inverses,strdup(estrutura->rel2),strdup(estrutura->rel1));
								return INV;
							}
(#).*						{
								yylval.string = yytext;
								return COMMENT;
							}							
[^ \n]+						{
								yylval.string = yytext; 
								return WORD;
							}												
[^ %\n]+\ (.)+				{
								char* res = until_space(yytext);
								if (g_tree_lookup(languages,res)) { // it's a language
									char* after = NULL;
									int spot;
									if (spot = after_space(yytext)) {
										after = malloc(sizeof(char)*(strlen(yytext)-spot+1));
										after[0] = '\0';
										strncpy(after,yytext+spot+1,strlen(yytext)-1);
									}
									struct info* estrutura = malloc(sizeof(struct info));
									estrutura->rel1 = strdup(res);
									estrutura->rel2 = strdup(after);
									yylval.ptr = estrutura;
									free(res);
									free(after);
									return TRANSLATION;
								}
								else if (g_hash_table_lookup(inverses,res)){ //it's a relation
									char* after = NULL;
									GList*	aux = NULL;
									int spot = after_space(yytext);
									if (spot) {
										after = strndup(yytext+spot+1,strlen(yytext)-1);
										int comma = has_comma(after);
										if (comma) {
											char* toTok = strtok(after,",");
											int it = 0;
											while (toTok){
												if (toTok[0]==' ') aux = g_list_append(aux,strndup(toTok+1,strlen(toTok)-1));
												else aux = g_list_append(aux,strdup(toTok));
												toTok = strtok(NULL,",");
												it++;
											}
										}
										else aux = g_list_append(aux,strdup(after));
									}																			
									else aux = g_list_append(aux,strdup(yytext));
									struct relation* estrutura = malloc(sizeof(struct relation));
									estrutura->term = strdup(res);
									estrutura->collection = g_list_copy_deep(aux,(GCopyFunc) strdup,NULL);
									yylval.rel = estrutura;
									g_list_free_full(aux,free);
									free(res);
									free(after);
									return RELATION;
								}
								else if (!strncmp(res,"SN",2)) { // Scope_Note
									yylval.string = yytext;
									free(res);
									return SCOPE;
								}
								else if (res[0] == '#') { // Comment
									yylval.string = yytext;
									free(res);
									return COMMENT;
								}
								else { // Term
									yylval.string = yytext; 
									free(res);
									return WORD;
								}
							}	
\n[\n]+						{
								return START_CONCEPT;
							}
.|\n 						{;}
%%

int yywrap(){
	g_hash_table_destroy(inverses);
	return 1;
}