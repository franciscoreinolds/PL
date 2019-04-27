BEGIN 	{	
			FS = "\t"; 
			RS = "\n"; 

		}


        {
            if($1=="<s>")   sentences++;
            if(match($1,/<p par=.+>/)){paragraphs++;}
            if(match($1,/<ext .+>/)){extracts++;}
        }

END     {

            print "Número de Frases: " sentences;
            print "Número de Parágrafos: " paragraphs;
            print "Número de Extratos: " extracts;

        }
