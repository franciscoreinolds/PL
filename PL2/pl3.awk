BEGIN 	{	
			FS = "\t"; 
			RS = "\n"; 

		}
	
	#awk -f pl3.awk < micromicro.txt | nl
	{
		if($5=="V") verbos[$4] += 1;
	}
 
END 	{
			for(verb in verbos) print verb " -> " verbos[verb];
			
		}
