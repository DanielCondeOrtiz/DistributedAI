/***
* Name: Project
* Author: Daniel Conde Ortiz and Enrique Perez Soler
* Description: 
***/

model Project

global {
	/** Insert the global definitions, variables and actions here */
	init{

		create Bar number: 1{
			
		}
		
		create Stage number: 1{
			
		}
		
		create ChillPeople number: 3{
			
		}
		
		create Partypeople number: 3{
			
		}
	}
}

species ChillPeople skills: [fipa,moving]{

	init{

	}
	

	aspect default{
		draw sphere(2) at: location color: #red;
	}
}


species Partypeople skills: [fipa,moving]{

	init{

	}
	

	aspect default{
		draw sphere(2) at: location color: #blue;
	}
}


species Bar  skills: [fipa]{


	init{
		
	}
	
	
	aspect default{
		draw cube(7) at: location color: #green;
	}
}

species Stage  skills: [fipa]{


	init{
		
	}
	
	
	aspect default{
		draw cube(7) at: location color: #blue;
	}
}



experiment Project type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display map type: opengl{
			species Stage;
			species Bar;
			species ChillPeople;
			species Partypeople;
		}
	}
}
