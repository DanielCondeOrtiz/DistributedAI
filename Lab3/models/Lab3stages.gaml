/***
* Name: Lab2
* Author: Daniel Conde Ortiz and Enrique Perez Soler
* Description: 
***/

model Lab3stages

global {
	/** Insert the global definitions, variables and actions here */
	init{

		create Stage number: 4{
			
		}
		
		create FestivalGuest number: 20{
			
		}
		
	}
}

species FestivalGuest skills: [fipa,moving]{

	float lights;
	float speakers;
	float band;
	float accesibility;
	float people;
	float field;
	
	float current_best;
	
	rgb color;
	
	Stage selected;
	
	list<Stage> stages;
	
	init{
		lights <- rnd(10)/10;
		speakers <- rnd(10)/10;
		band <- rnd(10)/10;
		accesibility <- rnd(10)/10;
		people <- rnd(10)/10;
		field <- rnd(10)/10;
		
		
		current_best <-0.0;
		
		selected <- nil;
		
		color <- #red;
		
		stages <-list(Stage);
		
		write length(stages);
	}
	
	reflex asking_for_info when: selected = nil or selected.concert_time = 0{
		current_best <-0.0;
		
		//cfp
		write self.name + ' asking stages';
		do start_conversation (to:: list(stages), protocol:: 'fipa-contract-net', performative:: 'cfp', contents:: ['What concerts do you have?']);
	}
	
	reflex read_proposes when: !(empty(proposes)){
		loop p over: proposes{
			
			float tmp <- float(p.contents[1])*lights + float(p.contents[2])*speakers + float(p.contents[3])*band  + float(p.contents[4])*accesibility + float(p.contents[5])*people + float(p.contents[6])*field;
			
			tmp <- tmp with_precision 2;
			
			if tmp > current_best{
				current_best <- tmp;
				selected <- p.sender;
				do accept_proposal (message: p, contents: ['I\'m coming!']);
				write self.name + ' New stage: ' + p.sender + ', value: ' + current_best;
			}
			else{
				do reject_proposal (message: p, contents: ['No, sorry']);
			}
			
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
	}
	
	
	reflex goToStage when: selected != nil{
		do goto (target: selected.location, speed: 1.5);
	}


	aspect default{
		draw sphere(2) at: location color: color;
		draw "Max: " + current_best at: location + {-3,3.2} color: #black font: font('Default', 12, #bold) ;
	}
	}

species Stage  skills: [fipa]{
	
	float lights;
	float speakers;
	float band;
	float accesibility;
	float people;
	float field;
	
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
		accesibility <- rnd(10)/10;
		people <- rnd(10)/10;
		field <- rnd(10)/10;
		
		concert_time <- rnd(50,100);
	}
	
	reflex decrease_time when: concert_time > 0{
		concert_time <- concert_time -1;
	}
	
	
	reflex reply when: (!empty(cfps)){
		message proposalFromInitiatior <- (cfps[0]);
			
		do propose with: (message: proposalFromInitiatior, contents: ['My values', lights, speakers, band,accesibility,people,field]);
	
	}
	
	
	aspect default{
		draw cube(7) at: location color: #blue;
		draw "Values: " + lights + ',' + speakers + ',' + band + ',' + accesibility + ',' + people  + ',' + field at: location + {-10,-7} color: #black font: font('Default', 12, #bold) ;
		draw "Time left: " + concert_time at: location + {-5,7} color: #black font: font('Default', 12, #bold) ;
		
	}
}



experiment Lab3stages type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display map type: opengl{
			species Stage;
			species FestivalGuest;
		}
	}
}
