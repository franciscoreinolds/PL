#ifndef INFO_H_HEADER_
#define INFO_H_HEADER_

typedef struct info {
  char* rel1;
  char* rel2;
}info;

typedef struct relation {
	char* term;
	GPtrArray* collection;
	int element_amount;
}relation;

#endif