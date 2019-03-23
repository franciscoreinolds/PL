#ifndef __TAG__
#define __TAG__



typedef struct tag* TAG;



TAG create_user(char* bio, int vezes) ;

int set(TAG u);

char* get_nome(TAG u) ;
int get_num(TAG u) ;
void free_user(TAG u);

#endif
