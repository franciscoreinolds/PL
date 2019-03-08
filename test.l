%{
#include <stdlib.h>
#include <stdlib.h>
%}
letter [a-zA-z]
%x NEWS
%%
"<pub>" 			{BEGIN NEWS;}
<NEWS>"</pub>" 		{BEGIN INITIAL;}
<NEWS>[.|\n] 		{printf("%s",yytext);}
.|\n {;}
%%

int yywrap(){
 return 1;
}

int main(){
 yylex();
 return 0;
}