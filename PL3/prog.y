%{
#include <stdio.h>
#include <gmodule.h>
#include <stdlib.h>
#include <glib.h>
#include "lex.yy.c"
#include "info.h"

int yylex();
int concs = 0;
int placeholder_size = 0;

char* baselang;


GTree* languages;
GHashTable* relations_table;
GHashTable* translations;
GArray* placeholder;
GString *s;

void print_relation(struct relation *toP){
	printf("PRINT_RELATION Term: %s\tElement_Amount: %d Size: %d\n",toP->term,toP->element_amount,toP->collection->len);
	int it = 0;
	while (it < toP->collection->len){
		GString* pls = g_ptr_array_index((toP->collection),it);
		printf("GArray[%d]: %s\n",it++,pls->str);
	}
}

int prettyEntry(char* key, char* value) {
  printf("PRETTYkey: %s\tvalue: %s\n", key, value);
  return 0;
}

void yyerror(char* s){
	printf("Erro sintático %s\n",s);
}
%}
%union 	{
			char* string;
			GTree* tree;
			GHashTable* map;
			struct info* ptr;
			struct relation* rel;
		}
%token <string> WORD
%token <string> BASE
%token <ptr> INV 
%token <ptr> TRANSLATION
%token <rel> RELATION
%token <tree> TRANS
%type <string> base
%token START_CONCEPT
%%

Program : trans base inverses Concepts
		;

trans 	:	TRANS 	{
						languages = $1;
						g_tree_foreach(languages, (GTraverseFunc) prettyEntry, NULL);
					}		
		;

base 	:	BASE 	{
						baselang = $1;
						printf("Base: %s\n",baselang);
					}
		;

inverses 	: 	inverse
			|	inverses inverse
			;

inverse 	:	INV 	{	
							struct info* estrutura;
							estrutura = $1;
							printf("Info.rel1: %s\n", estrutura->rel1);
							g_hash_table_insert(relations_table,strdup(estrutura->rel1),strdup(estrutura->rel2));
							g_hash_table_insert(relations_table,strdup(estrutura->rel2),strdup(estrutura->rel1));				
						}
			;		

Concepts 	:	Concept
			|	Concepts 	Concept
			;

Concept 	:	START_CONCEPT	Base_Term	Translations 	Relations 	{

																		}
			;


Base_Term 	:	WORD 	{
							printf("Hi: %s\n",$1);
						}
			;

Translations	:	Translation
				|	Translations	Translation
				;

Translation	:	TRANSLATION	{
								struct info* toInsert;
								toInsert = $1;
								g_hash_table_insert(translations,toInsert->rel1,toInsert->rel2);
							}
			;

Relations 	:	Relation
			|	Relations 	Relation
			;

Relation 	:	RELATION 	{
								struct relation* toPrint;
								toPrint = $1;
								int it = 0;
								while (it < toPrint->collection->len){
									GString* pls = g_ptr_array_index((toPrint->collection),it);
									printf("GArray[%d]: %s\n",it++,pls->str);
								}
							}
			;

%%

int main(){
	languages =  g_tree_new((GCompareFunc)strcmp);
	relations_table = g_hash_table_new_full(g_str_hash,g_str_equal,free,NULL);
	translations = g_hash_table_new_full(g_str_hash,g_str_equal,free,NULL);
	placeholder = g_array_new(FALSE, FALSE, sizeof(GString *));
	yyparse();
	g_tree_destroy(languages);
	GHashTableIter iter;
	gpointer key1;
	gpointer value1;
	g_hash_table_iter_init (&iter, translations);
	while (g_hash_table_iter_next (&iter, &key1, &value1)) {
		gchar* key = (gchar*) key1;
		gchar* value = (gchar*) value1;
		printf("Translations: %s <> %s \n",key,value);
	}
	return(0);
}