#ifndef __MY_COMMON__
#define __MY_COMMON__

#include <gmodule.h>


/**
@file common.h
Definição do funções comuns a vários headers.
*/


/**
  Estrutura que define uma sequência.
  A sequência é da biblioteca do glib (struct GSequence*), sendo que a sua estrututa possui a API de uma lista, mas é implementada internamente como uma árvore binária balanceada.
*/

typedef GSequence* SEQUENCIA;


/**
Estrutura que define uma um apontadore de uma sequência.
A apontador é da biblioteca do glib (struct GSequenceIter*).
*/
typedef GSequenceIter* SEQITERADOR;


/**
\brief Função que aloca memória para uma string (char*);
@param Uma string (char*).
@returns A mesma string, mas com espaço alocado. Caso não seja possível alocar memória ou a string seja NULL, retorna NULL.
*/
char * mystrdup (const char *s);
#endif
