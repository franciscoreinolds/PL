BEGIN     {
    FS = "\t";
    RS = "\n";
	c=0;
	t=0;
        }

    #awk -f pl2.awk < micromicro.txt | nl
    {
        if(match($1,/<mwe pos=.+>/)) c=1;
		if(match($1,"</mwe>")){
			 c=0;
			 t=0;
			 for(word in string) {
				if(t==0) var=word;
				else var=final " " word;
				final=var;
				t++;s
			 };

			 for (word in string) delete string[word];
			 aux[final] += 1; 
		};
        if(c==1){ 
			if( $0 !~/<mwe pos=.+>/ )  string[$1] ;
		};


    }

END     {
            for(mwe in aux) print mwe " -> " aux[mwe];
}
