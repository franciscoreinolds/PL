#include<stdio.h>

void
free_data (gpointer data)
{
  printf ("freeing: %s %p\n", (char *) data, data);
  free (data);
}
