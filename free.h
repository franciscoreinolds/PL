#include<stdio.h>
#define gp_to_int(p) ((gint)  (glong) (p))
#define gi_to_ptr(i) ((gpointer) (glong) (i))

void free_data (gpointer data) {
  free (data);
}