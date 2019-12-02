/***
* Name: Project
* Author: Daniel Conde Ortiz and Enrique Perez Soler
* Description: 
***/

model Project

global {
	/** Insert the global definitions, variables and actions here */
	init{

		create Cantine number: 1{
			
		}
		
		create Store number: 1{
			
		}
		
		create Stage number: 3{
			
		}
		
		create OTFan number: 3{
			
		}
		
		create PrequelsFan number: 3{
			
		}
		
		create DisneySWFan number: 3{
			
		}
	}
}

species OTFan skills: [fipa,moving]{

	float OTPref;
	float PreqPref;
	float DisneyPref;
	
	float noiseResistance;
	
	bool smokes;
	
	DisneySWFan child;

	init{

		OTPref<- 10.0;
		PreqPref<- rnd(0,5)/10;
		DisneyPref<- rnd(0,3)/10;

		noiseResistance <- rnd(10)/10;
		
		child <-nil;
		
		smokes<- flip(0.5);

	}
	

	aspect default{
		draw sphere(2) at: location color: #red;
	}
}


species PrequelsFan skills: [fipa,moving]{

	float OTPref;
	float PreqPref;
	float DisneyPref;
	
	float noiseResistance;

	init{

		OTPref<- rnd(7,9)/10;
		PreqPref<- rnd(7,10)/10;
		DisneyPref<- rnd(0,5)/10;
		
		noiseResistance <- rnd(10)/10;
	}
	

	aspect default{
		draw sphere(2) at: location color: #blue;
	}
}

species DisneySWFan skills: [fipa,moving]{

	float OTPref;
	float PreqPref;
	float DisneyPref;
	
	float noisy;
	
	OTFan parent;

	init{

		OTPref<- rnd(5,8)/10;
		PreqPref<- rnd(5,10)/10;
		DisneyPref<- rnd(7,10)/10;
		
		noisy <- rnd(10)/10;
		
		parent <- nil;
		
		
		//mitad aleatorio
		loop while: parent = nil{
			
			OTFan tmp <- one_of(OTFan);
			
			if tmp.child = nil{
				parent.child <- self;
			}
		}
	}
	

	aspect default{
		draw sphere(2) at: location color: #red;
	}
}


species Cantine skills: [fipa]{


	init{
		location <- {0,50,0};
	}
	
	
	aspect default{
		draw cube(7) at: location color: #green;
	}
}

species Store skills: [fipa]{

	init{
		location <- {0,0,0};
		
	}
	
	
	aspect default{
		draw cube(7) at: location color: #yellow;
	}
}

species Stage skills: [fipa]{

	int order;

	// 1 = OT
	// 2 = Preq
	// 3 = Disney
	int current;

	int concert_time;

	init{
		order <- int(self);

		//Position		
		if order = 0{
			location <- {50,0,0};
		}
		else if order = 1{
			location <- {50,100,0};
		}
		else if order = 2{
			location <- {100,50,0};
		}
		
		// 1 = OT
		// 2 = Preq
		// 3 = Disney
		current <- rnd (1,3);
		
		concert_time <-0;
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
			species Cantine;
			species Store;
			species OTFan;
			species PrequelsFan;
			species DisneySWFan;
		}
	}
}
