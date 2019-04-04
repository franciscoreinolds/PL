#include "aux.h"
#define gp_to_int(p) ((gint)  (glong) (p))
#define gi_to_ptr(i) ((gpointer) (glong) (i))

void free_data (gpointer data) {
  free (data);
}

void removeChar(char *s, int c){ 
  
    int j, n = strlen(s); 
    for (int i=j=0; i<n; i++) 
       if (s[i] != c) 
          s[j++] = s[i]; 
      
    s[j] = '\0'; 
}

void addsTags(gpointer data, gpointer user_data){
	char* toI = strdup((gchar*) data);
	GHashTable* hash = (GHashTable*) user_data;
	if(!g_hash_table_lookup(hash, toI)){
		g_hash_table_insert (hash, toI, gi_to_ptr(1));
	}	
	else {
		gint* res = g_hash_table_lookup(hash,toI);
		int toAdd = gp_to_int(res)+1;
		g_hash_table_replace (hash,toI,gi_to_ptr(toAdd));
	}
}