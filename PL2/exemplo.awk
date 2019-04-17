BEGIN 	{
			FS = "\t"; 
			RS = "\n"; 
		}
	
	#awk -f pl2.awk < micromicro.txt | nl

	{
		printf ("NR:%d $0:%s\n",NR,$0);
	}

	#if(!strncmp($1,"<e",2))
	#if(!strncmp($1,"<p",2))
	#if(!strncmp($1,"<s",2))
	#if(!strncmp($1,"<m",2))
 
END 	{
			printf("Oi\n");
		}