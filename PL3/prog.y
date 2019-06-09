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
GHashTable* concepts_table;
GHashTable* relations_terms;
GHashTable* relations_table;
GHashTable* translations;
GArray* placeholder;
GString *s;

/*
void print_relation(struct relation *toP){
	printf("PRINT_RELATION Term: %s\tElement_Amount: %d Size: %d\n",toP->term,toP->element_amount,toP->collection->len);
	int it = 0;
	while (it < g_list_letoP->collection->len){
		GString* pls = g_ptr_array_index((toP->collection),it);
		printf("GArray[%d]: %s\n",it++,pls->str);
	}
}
*/
int prettyEntry(char* key, char* value) {
  printf("PRETTYkey: %s\tvalue: %s\n", key, value);
  return 0;
}

void print(gpointer key, gpointer value, gpointer data) {
 printf("Here are some cities in %s: ", (gchar*) key);
 g_slist_foreach((GSList*)value, (GFunc)printf, NULL);
 printf("\n");
}

void prints_relations(GHashTable* toPrint){
	GHashTableIter iter;
	gpointer key1;
	gpointer value1;
	g_hash_table_iter_init (&iter, toPrint);
	while (g_hash_table_iter_next (&iter, &key1, &value1)) {
		gchar* key = (gchar*) key1;
		GList* value = (GList*) value1;
		printf("Relations: %s <> %d \n",key,g_list_length(value));
		int i = 0;
		while (i < g_list_length(value)){
			printf("Data at: %d is %s\n",i, (gchar*) g_list_nth_data(value,i));
			i++;
		}
	}
}

void prints_translations(GHashTable* toPrint){
	GHashTableIter iter;
	gpointer key1;
	gpointer value1;
	g_hash_table_iter_init (&iter, toPrint);
	while (g_hash_table_iter_next (&iter, &key1, &value1)) {
		gchar* key = (gchar*) key1;
		gchar* value = (gchar*) value1;
		printf("Translations: %s <> %s \n",key,value);
	}
}

GHashTable* copy_translations (GHashTable* hash){
	GHashTable* res = g_hash_table_new_full(g_str_hash,g_str_equal,free,NULL);
	GHashTableIter iter;
	gpointer key1;
	gpointer value1;
	g_hash_table_iter_init (&iter, hash);
	while (g_hash_table_iter_next (&iter, &key1, &value1)) {
		gchar* key = (gchar*) key1;
		gchar* value = (gchar*) value1;
		g_hash_table_insert(res,strdup(key),strdup(value));
	}
	return res;
}

GHashTable* copy_relations (GHashTable* hash){
	GHashTable* res = g_hash_table_new_full(g_str_hash,g_str_equal,free,NULL);
	GHashTableIter iter;
	gpointer key1;
	gpointer value1;
	g_hash_table_iter_init (&iter, hash);
	/*
		GList* lista = NULL;
		int length = g_list_length(rel->collection);
		
		if (lista = g_hash_table_lookup(relations_terms,rel->term)) {
			i = 0;
			while (i < length) lista = g_list_append(lista,g_list_nth_data(rel->collection,i++));
			g_hash_table_insert(relations_terms,rel->term,lista);
		}
	*/
	while (g_hash_table_iter_next (&iter, &key1, &value1)) {
		gchar* key = (gchar*) key1;
		GList* value = (GList*) value1;
		printf("Relations: %s <> %d \n",key,g_list_length(value));
		GList* copy = g_list_copy_deep(value,(GCopyFunc) strdup,NULL);
		g_hash_table_insert(res,strdup(key),copy);
	}
	return res;
}

void print_concepts() {
	printf("Size: %d\n",g_hash_table_size(concepts_table));
	GHashTableIter iter;
	gpointer key1;
	gpointer value1;
	g_hash_table_iter_init (&iter, concepts_table);
	while (g_hash_table_iter_next (&iter, &key1, &value1)) {
		gchar* key = (gchar*) key1;
		struct concept* value = value1;
		puts("------------------");
		printf("\nConcept!\n");
		printf("Term -> %s\n",key);
		printf("\nRelations and Terms\n");
		prints_relations(value->relations);
		printf("\nAvailable Translations\n");
		prints_translations(value->translations);
		puts(" ");
	}
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
%type <string> Base_Term
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
																			/*
																			printf("\nConcept!\n");
																			printf("Base Language: %s\n",baselang);
																			printf("Base Term: %s\n",$2);
																			printf("Translated Languages\n");
																			g_tree_foreach(languages, (GTraverseFunc) prettyEntry, NULL);
																			printf("\nRelations and Terms!\n");
																			prints_relations(relations_terms);
																			printf("\nAvailable Translations!\n");																																						printf("Relations and Terms!\n");
																			prints_translations(translations);
																			puts("CONCEPT END\n");
																			*/


																			struct concept* Con = malloc(sizeof(struct concept)); 
																			Con->term = strdup($2);
																			Con->translations = copy_translations(translations);
																			Con->relations = copy_relations(relations_terms);
																			g_hash_table_insert(concepts_table,Con->term,Con);
																			g_hash_table_remove_all(relations_terms);
																			g_hash_table_remove_all(translations);

																			}
			;


Base_Term 	:	WORD 	{
							$$ = $1;
							printf("Hi: %s\n",$1);
						}
			;

Translations	:	Translation
				|	Translations	Translation
				;

Translation	:	TRANSLATION	{
								struct info* toInsert;
								toInsert = $1;
								printf("Gonna insert into translations %s -> %s\n",toInsert->rel1,toInsert->rel2);
								g_hash_table_insert(translations,strdup(toInsert->rel1),strdup(toInsert->rel2));
							}
			;

Relations 	:	Relation
			|	Relations 	Relation
			;

Relation 	:	RELATION 	{
								struct relation* rel;
								rel = $1;
								int ite = 0;
								GList* lista = NULL;
								int i = 0;
								int length = g_list_length(rel->collection);
								if (lista = g_hash_table_lookup(relations_terms,rel->term)) {
									i = 0;
									while (i < length) lista = g_list_append(lista,g_list_nth_data(rel->collection,i++));
									g_hash_table_insert(relations_terms,rel->term,lista);
								}
								else {
									GList* toInsert = g_list_copy_deep(rel->collection,(GCopyFunc)strdup,NULL);
									g_hash_table_insert(relations_terms,rel->term,toInsert);
								}
								
							}
			;

%%

int main(){
	concepts_table = g_hash_table_new_full(g_str_hash,g_str_equal,free,NULL);
	languages =  g_tree_new((GCompareFunc)strcmp);
	relations_terms = g_hash_table_new_full(g_str_hash,g_str_equal,free,NULL);
	relations_table = g_hash_table_new_full(g_str_hash,g_str_equal,free,NULL);
	translations = g_hash_table_new_full(g_str_hash,g_str_equal,free,NULL);
	placeholder = g_array_new(FALSE, FALSE, sizeof(GString *));
	yyparse();
	puts("----------------");
	print_concepts();

	g_tree_destroy(languages);
	
	/*
	GHashTableIter iter;
	gpointer key1;
	gpointer value1;
	g_hash_table_iter_init (&iter, relations_terms);
	while (g_hash_table_iter_next (&iter, &key1, &value1)) {
		gchar* key = (gchar*) key1;
		GList* value = (GList*) value1;
		printf("Relations: %s <> %d \n",key,g_list_length(value));
		int i = 0;
		while (i < g_list_length(value)){
			printf("Data at: %d is %s\n",i, (gchar*) g_list_nth_data(value,i));
			i++;
		}
	}
	*/	
	return(0);
}