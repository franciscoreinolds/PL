BEGIN 	{	
			FS = "\t"; 
			RS = "\n"; 

		}
	
	#awk -f pl4.awk < micro-Cetempublico01.txt | nl > resultado.txt
	
	{
		$1 !~/^</ {verbos[$1][$4][$5];}
	}
 
END 	{
			for (i in verbos) {
				for(j in verbos[i]) {
					for (k in verbos[i][j]) printf("%s -> ( %s , %s 	)\n",i,j,k);
				}
			}
		}