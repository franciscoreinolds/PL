#include <string.h>
#include <stdlib.h>
#include "tag.h"
#include <stdio.h>

struct tag {
  char* nome;
  int num;
};

TAG create_user(char* bio, int vezes) {
  TAG u = malloc(sizeof(struct tag));
  u->nome = mystrdup(bio);
  u->num = vezes;
  return u;
}

char* get_nome(TAG u) {
  if(u)
    return u->nome;
  return NULL;
}

int get_num(TAG u) {
  if(u)
    return u->num;
}


int set(TAG u){
  if(u){
   	u->num = u->num+1;
    return 0;
  }
  return 1 ;
}


void free_user(TAG u) {
  if(u) {
    free(u->nome);
    free(u);
  }
}


