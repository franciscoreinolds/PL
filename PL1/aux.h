#ifndef aux_h   /* Include guard */
#define aux_h
#include <stdio.h>
#include <string.h>
#include <glib.h>

void free_data (gpointer data);
void removeChar(char *s, int c);
void addsTags(gpointer data, gpointer user_data);
#endif