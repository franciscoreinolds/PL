BEGIN     {
    FS = "\t";
    RS = "\n";
    c=0;
        }

    #awk -f pl2.awk < micromicro.txt | nl
    {
        if(match($1,/<mwe pos=.+>/)) c=1;
	if(match($1,"</mwe>")) c=0;
        if(c==1){ 
		if( $0 !~/<mwe pos=.+>/ )  aux[$1] += 1; 
		};


    }

END     {
            for(mwe in aux) print mwe " -> " aux[mwe];

}
