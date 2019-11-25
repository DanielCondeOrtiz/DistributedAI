/***
* Name: Lab2
* Author: Daniel Conde Ortiz and Enrique Perez Soler
* Description: 
***/

model Lab3stages

global {
	/** Insert the global definitions, variables and actions here */
	init{
		create FestivalGuest number: 1{
			
		}
		
		create Stage number: 4{
			
		}
		
	}
}

species FestivalGuest skills: [fipa,moving]{

	float lights;
	float speakers;
	float band;
	
	rgb color;
	
	Stage selected;
	
	init{
		lights <- rnd(10)/10;
		speakers <- rnd(10)/10;
		band <- rnd(10)/10;
		
		selected <- nil;
		
		color <- #red;
	}
	
	
	reflex change_stages when: selected = nil or selected.concert_time = 0{
		selected <- one_of(Stage);
		
		if selected.order = 0{
			color <- #red;
		}
		else if selected.order = 1{
			color <- #cyan;
		}
		else if selected.order = 2{
			color <- #green;
		}
		else{
			color <- #yellow;
		}
	}
	
	reflex goToStage when: selected != nil{
		do goto (target: selected.location, speed: 2.0);
	}


	aspect default{
		draw sphere(2) at: location color: color;
	}
	}

species Stage  skills: [fipa]{
	
	float lights;
	float speakers;
	float band;
	
	int concert_time;
	
	int order;

	init{
		concert_time <-0;
		
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
		else{
			location <- {0,50,0};
		}
		
		
		
	}

	reflex new_concert when: concert_time = 0{
		lights <- rnd(10)/10;
		speakers <- rnd(10)/10;
		band <- rnd(10)/10;
		
		
		concert_time <- rnd(50,100);
	}
	
	reflex decrease_time when: concert_time > 0{
		concert_time <- concert_time -1;
	}
	
	
	
	aspect default{
		draw cube(8) at: location color: #blue;
	}
}



experiment Lab3stages type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display map type: opengl{
			species FestivalGuest;
			species Stage;
		}
	}
}
