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

GList* comments;
GList* scope_notes;

GString *s;

int prettyEntry(char* key, char* value) {
  printf("PRETTYkey: %s\tvalue: %s\n", key, value);
  return 0;
}

void print(gpointer key, gpointer value, gpointer data) {
 printf("Here are some cities in %s: ", (gchar*) key);
 g_slist_foreach((GSList*)value, (GFunc)printf, NULL);
 printf("\n");
}

void prints_glist (GList* toPrint, char* list_type){
	int lim = g_list_length(toPrint);
	int it = 0;
	while (it < lim) printf("%s[%d] -> %s\n",list_type,it,(gchar*) g_list_nth_data(toPrint,it++));
}

void prints_relations(GHashTable* toPrint){
	GHashTableIter iter;
	gpointer key1;
	gpointer value1;
	g_hash_table_iter_init (&iter, toPrint);
	while (g_hash_table_iter_next (&iter, &key1, &value1)) {
		gchar* key = (gchar*) key1;
		GList* value = (GList*) value1;
		//printf("Relations: %s <> %d \n",key,g_list_length(value));
		int i = 0;
		while (i < g_list_length(value)){
			printf("%s[%d] -> %s\n", key , i , (gchar*) g_list_nth_data(value,i));
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

void concept_destroyer (gpointer data) {
	/*
	struct concept* estrutura = *(concept**) data;
	char* aux = (char*) (data->term);
	char* aux = (char*) estrutura->term;
	printf("Term: %s\n", aux);
	*/
	struct concept* estrutura = data;
	g_list_free_full(estrutura->scope,free);
	g_list_free_full(estrutura->comments,free);
	
	g_hash_table_remove_all(estrutura->translations);
	g_hash_table_destroy(estrutura->translations);
	
	g_hash_table_remove_all(estrutura->relations);
	g_hash_table_destroy(estrutura->relations);
}

void relation_destroyer(gpointer data) {
	g_list_free_full((GList*) data,free);
}

GHashTable* copy_translations (GHashTable* hash){
	GHashTable* res = g_hash_table_new_full(g_str_hash,g_str_equal,free,free);
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
	GHashTable* res = g_hash_table_new_full(g_str_hash,g_str_equal,free,relation_destroyer);
	GHashTableIter iter;
	gpointer key1;
	gpointer value1;
	g_hash_table_iter_init (&iter, hash);

	while (g_hash_table_iter_next (&iter, &key1, &value1)) {
		gchar* key = (gchar*) key1;
		GList* value = (GList*) value1;
		//printf("Relations: %s <> %d \n",key,g_list_length(value));
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
		printf("\nConcept\n");
		printf("Term -> %s\n",key);
		printf("\nRelations and Terms\n");
		prints_relations(value->relations);
		printf("\nAvailable Translations\n");
		prints_translations(value->translations);
		if (g_list_length(value->comments)) {
			printf("\nAvailable Comments\n");
			prints_glist(value->comments,"Comments");
		}
		if (g_list_length(value->scope)) {
			printf("\nAvailable Scope Notes\n");
			prints_glist(value->scope,"Scope Notes");
		}
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
%token <string> WORD BASE COMMENT SCOPE
%token <ptr> INV TRANSLATION
%token <rel> RELATION
%token <tree> TRANS
%type <string> Base_Term base Scope_Note Comment
%token START_CONCEPT
%%

Program : Languages Concepts
		;

Languages 	:	Language 
			|	Languages Language
			;

Language 	: 	trans
			| 	base 
			|	inverses
			;


trans 	:	TRANS 	{
						languages = $1;
					}		
		;

base 	:	BASE 	{
						baselang = $1;
					}
		;

inverses 	: 	inverse
			|	inverses inverse
			;

inverse 	:	INV 	{	
							g_hash_table_insert(relations_table,strdup($1->rel1),strdup($1->rel2));
							g_hash_table_insert(relations_table,strdup($1->rel2),strdup($1->rel1));
						}
			;		

Concepts 	:	Concept
			|	Concepts 	Concept
			;

Concept 	:	START_CONCEPT	Base_Term 	Elements 	{	
																			struct concept* Con = malloc(sizeof(struct concept));
																			//printf("Con->term: %s\n",$2);
																			Con->term = NULL;
																			Con->term = strdup($2);
																			Con->translations = copy_translations(translations);
																			Con->relations = copy_relations(relations_terms);
																			Con->scope = g_list_copy_deep(scope_notes,(GCopyFunc) strdup,NULL);
																			Con->comments = g_list_copy_deep(comments,(GCopyFunc) strdup,NULL);
																			g_hash_table_insert(concepts_table,Con->term,Con);

																			g_list_free_full(comments,(GDestroyNotify) free);
																			comments = NULL;
																			g_list_free_full(scope_notes,(GDestroyNotify) free);
																			scope_notes = NULL;
																			g_hash_table_remove_all(relations_terms);
																			g_hash_table_remove_all(translations);
																		}
			;

Elements 	:	Element
			|	Elements	Element
			;

Element 	:	Translations
			|	Relations
			|	Scope_Notes
			|	Comments
			;

Scope_Notes	:	Scope_Note
			|	Scope_Notes 	Scope_Note
			;

Scope_Note 	:	SCOPE 	{
							scope_notes = g_list_append(scope_notes,strdup($1+3));
						}
			;

Comments 	:	Comment
			|	Comments	Comment
			;

Comment 	:	COMMENT 	{
								comments = g_list_append(comments,strdup($1+1));
							}
			;

Base_Term 	:	WORD 	{
							$$ = $1;
						}
			;

Translations	:	Translation
				|	Translations	Translation
				;

Translation	:	TRANSLATION	{
								//printf("Gonna insert into translations %s -> %s\n",toInsert->rel1,toInsert->rel2);
								g_hash_table_insert(translations,strdup($1->rel1),strdup($1->rel2));
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
									g_hash_table_insert(relations_terms,rel->term,g_list_copy_deep(rel->collection,(GCopyFunc)strdup,NULL));
									g_list_free_full(rel->collection,free);
								}
								
							}
			;

%%

int main(){
	concepts_table = g_hash_table_new_full(g_str_hash,g_str_equal,free,(GDestroyNotify) concept_destroyer);
	relations_terms = g_hash_table_new_full(g_str_hash,g_str_equal,free,relation_destroyer);
	relations_table = g_hash_table_new_full(g_str_hash,g_str_equal,free,free);
	translations = g_hash_table_new_full(g_str_hash,g_str_equal,free,free);

	languages =  g_tree_new_full((GCompareDataFunc)strcmp,NULL,free,free);
	
	placeholder = g_array_new(FALSE, FALSE, sizeof(GString *));
	comments = NULL;
	scope_notes = NULL;

	yyparse();
	puts("------------------");
	print_concepts();

	if (g_hash_table_size(concepts_table)) g_hash_table_remove_all(concepts_table);
	g_hash_table_destroy(concepts_table);

	if (g_hash_table_size(relations_terms)) g_hash_table_remove_all(relations_terms);
	g_hash_table_destroy(relations_terms);

	if (g_hash_table_size(relations_table)) g_hash_table_remove_all(relations_table);
	g_hash_table_destroy(relations_table);

	if (g_hash_table_size(translations)) g_hash_table_remove_all(translations);
	g_hash_table_destroy(translations);

	g_tree_destroy(languages);

	free(baselang);

	return(0);
}