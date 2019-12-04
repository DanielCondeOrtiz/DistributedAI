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
		
		create Stage number: 3{
			
		}
		
		create OTFan number: 20{
			
		}
		
		create PrequelsFan number: 20{
			
		}
		
		create DisneySWFan number: 20{
			
		}
	}
}

species OTFan skills: [fipa,moving]{

	float OTPref;
	float PreqPref;
	float DisneyPref;
	
	float noiseResistance;
	float generous;
	int justBought;
	
	bool smokes;
	
	DisneySWFan child;
	
	int hunger;
	bool needToEat;
	point cantineLocation;
	
	point targetPoint;
	float maxDistancePoint;
	float maxDistanceRadius;
	
	bool previouslyChecked;

	init{

		OTPref<- 10.0;
		PreqPref<- rnd(0,5)/10;
		DisneyPref<- rnd(0,3)/10;

		noiseResistance <- rnd(10)/10;
		generous <- rnd(10)/10;
		justBought<-0;
		
		child <-nil;
		
		smokes<- flip(0.5);
		
		hunger <- rnd(200,250);
		needToEat <- false;
		ask Cantine{
			myself.cantineLocation <- self.location;
		}
		
		targetPoint <- nil;
		maxDistancePoint<-7.0;
		maxDistanceRadius<-10.0;

		previouslyChecked<-false;
	}
	
	reflex get_hungry when: hunger > 0{
		if flip(0.8){
			hunger<- hunger - 1;
		}
		
		if hunger = 0{
			targetPoint<-cantineLocation;
			needToEat <- true;
		}
	}
	
	reflex eating when: needToEat and location distance_to(cantineLocation) <= maxDistancePoint{
		hunger <- hunger + 10;
		
		if hunger > 200 and flip(0.8){
			needToEat<- false;
			targetPoint<-nil;
			
			previouslyChecked<-false;	
		}
		 
		//Leaves if too many DisneyFans eating in the same place
		if length(agents_at_distance(maxDistanceRadius) of_species (DisneySWFan) ) > 10 and !previouslyChecked{
			
			if agents_at_distance(maxDistanceRadius) of_species (DisneySWFan) one_matches (each.parent = self){
				write self.name + ' too much Disney eating here! But my kid is here';
				previouslyChecked<-true;
			} else{
				write self.name + ' too much Disney eating here! I\'m leaving';
			
				needToEat<- false;
				targetPoint<-nil;				
				
				if hunger < 100{
					hunger<-100;
				}
				
				previouslyChecked<-false;
				justBought<-0;
			}

		}
		
		if justBought > 0{
			justBought<-justBought -1;
		}
		
	}
	
	reflex replyBuy when: (!empty(requests)){
		message proposalFromInitiatior <- (requests[0]);
		
		string tmp<-string(proposalFromInitiatior.contents);
		
		if flip(generous) and justBought < generous*10{
			
			justBought<- justBought+1;
			
			do agree with: (message: proposalFromInitiatior, contents: ['Okay!']);
		}else{
			do cancel with: (message: proposalFromInitiatior, contents: ['No, sorry']);
		}
		
	}
	
	reflex choosePlace when: targetPoint = nil{
		targetPoint <- {rnd(100),rnd(100)};
	}
	
	reflex goToDest when: targetPoint != nil{
		if location distance_to(targetPoint) > maxDistancePoint{
			do goto target: targetPoint;	
		}
		
	}
	
	aspect default{
		draw sphere(2) at: location color: #red;
		//draw circle(maxDistanceRadius) at: location color: #black;
		//draw 'O' at: location + {-0.8,0.8,5} color: #black font: font('Default', 20, #bold) ;
		
	}
}


species PrequelsFan skills: [fipa,moving]{

	float OTPref;
	float PreqPref;
	float DisneyPref;
	
	float noiseResistance;

	int hunger;
	bool needToEat;
	point cantineLocation;

	point targetPoint;
	float maxDistancePoint;
	float maxDistanceRadius;
	
	int timeSinceLastAsked;
	int agreesNum;
	

	init{

		OTPref<- rnd(7,9)/10;
		PreqPref<- rnd(7,10)/10;
		DisneyPref<- rnd(0,5)/10;
		
		noiseResistance <- rnd(10)/10;
		
		hunger <- rnd(200,250);
		needToEat <- false;
		ask Cantine{
			myself.cantineLocation <- self.location;
		}
		
		targetPoint <- nil;
		maxDistancePoint<-6.0;
		maxDistanceRadius<-10.0;
		
		timeSinceLastAsked<-0;
		agreesNum<-0;
	}
	
	reflex get_hungry when: hunger > 0{
		if flip(0.8){
			hunger<- hunger - 1;
		}
		
		if hunger = 0{
			targetPoint<-cantineLocation;
			needToEat <- true;
		}
	}
	
	reflex eating when: needToEat and location distance_to(cantineLocation) <= maxDistancePoint {
		hunger <- hunger + 10;
		
		if hunger > 200 and flip(0.8){
			needToEat<- false;
			targetPoint<-nil;		
			timeSinceLastAsked<-0;	
		}
		
		
		if timeSinceLastAsked=0 and length( agents_at_distance(maxDistanceRadius) of_species (OTFan)) >0{
			//request to buy
			write self.name + ' asking OTFans if buying a drink';
			do start_conversation (to:: agents_at_distance(maxDistanceRadius) of_species (OTFan), protocol:: 'fipa-request', performative:: 'request', contents:: ['Buy drink?']);
		
			timeSinceLastAsked<-1;
			agreesNum<-0;
		}else{
			timeSinceLastAsked<-timeSinceLastAsked+1;
			
			if timeSinceLastAsked = 50{
				timeSinceLastAsked<- 0;
			}
		}
	}
	
	
	reflex read_agrees when: !(empty(agrees)){
		loop a over: agrees{
			string tmp <- string(a.contents);
			
			agreesNum<- agreesNum + 1;
			
			//Calls for more
			if agreesNum > length(agents_at_distance(maxDistanceRadius) of_species (PrequelsFan) ){
				write self.name + ' calls for more people';
				//do start_conversation (to:: [one_of(list(PrequelsFan) - agents_at_distance(maxDistanceRadius) of_species (PrequelsFan))], protocol:: 'fipa-contract-net', performative:: 'inform', contents:: ['Someone is buying drinks']);
			}
		}
	}
	
	reflex read_informs when: !(empty(informs)){
		loop i over: informs{
			string tmp <- string(i.contents);
			
			//Someone is buying drinks
			if agent(i.sender) = PrequelsFan{
				write self.name + ' going for drinks!';
				targetPoint <-cantineLocation;
			}
			
		}
	}
	
	reflex read_cancels when: !(empty(cancels)){
		loop f over: cancels{
			string tmp <- string(f.contents);
		}
	}
	
	reflex choosePlace when: targetPoint = nil{
		targetPoint <- {rnd(100),rnd(100)};
	}
	
	reflex goToDest when: targetPoint != nil{

		if location distance_to(targetPoint) > maxDistancePoint{
			do goto target: targetPoint;	
		}
		
	}
	

	aspect default{
		draw sphere(2) at: location color: #cyan;
		//draw 'P' at: location + {-0.8,0.8,5} color: #black font: font('Default', 20, #bold) ;
	}
}

species DisneySWFan skills: [fipa,moving]{

	float OTPref;
	float PreqPref;
	float DisneyPref;
	
	float noisy;
	
	OTFan parent;

	int hunger;
	bool needToEat;
	point cantineLocation;

	point targetPoint;
	float maxDistancePoint;
	float maxDistanceRadius;
	
	bool previouslyChecked;
	

	init{

		OTPref<- rnd(5,8)/10;
		PreqPref<- rnd(5,10)/10;
		DisneyPref<- rnd(7,10)/10;
		
		noisy <- rnd(10)/10;
		
		parent <- nil;
		
		//Half of them get parents
		if flip(0.5){
			loop while: parent = nil{
				
				OTFan tmp <- one_of(OTFan);
				
				if tmp.child = nil{
					parent<-tmp;
					parent.child <- self;
					
				}
			}	
		}
		
		hunger <- rnd(200,250);
		needToEat <- false;
		ask Cantine{
			myself.cantineLocation <- self.location;
		}
		
		targetPoint <- nil;
		maxDistancePoint<-5.0;
		maxDistanceRadius<-10.0;
		
		previouslyChecked<-false;
		
	}
	
	reflex get_hungry when: hunger > 0{
		if flip(0.8){
			hunger<- hunger - 1;
		}
		
		if hunger = 0{
			targetPoint<-cantineLocation;
			needToEat <- true;
		}
	}
	
	reflex eating when: needToEat and location distance_to(cantineLocation) <= maxDistancePoint + 0.1{
		hunger <- hunger + 10;
		
		if hunger > 200 and flip(0.8){
			needToEat<- false;
			targetPoint<-nil;
			
			previouslyChecked<-false;	
		}
		 
		//Leaves if too many DisneyFans eating in the same place
		if length(agents_at_distance(maxDistanceRadius) of_species (PrequelsFan) ) > 10 and !previouslyChecked{
			
			if agents_at_distance(maxDistanceRadius) of_species (OTFan) one_matches (each.child = self){
				write self.name + ' too much PrequelFan eating here! But my parent is here';
				previouslyChecked<-true;
			} else{
				write self.name + ' too much PrequelFan eating here! I\'m leaving';
			
				needToEat<- false;
				targetPoint<-nil;				
				
				if hunger < 100{
					hunger<-100;
				}
				
				previouslyChecked<-false;
			}

		}
	}
	
	reflex choosePlace when: targetPoint = nil{
		targetPoint <- {rnd(100),rnd(100)};
	}
		
	reflex goToDest when: targetPoint != nil{


		if location distance_to(targetPoint) > maxDistancePoint{
			do goto target: targetPoint;	
		}
		
	}
	

	aspect default{
		draw sphere(2) at: location color: #green;
		//draw 'D' at: location + {-0.8,0.8,5} color: #black font: font('Default', 20, #bold) ;
		
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
			species OTFan;
			species PrequelsFan;
			species DisneySWFan;
		}
		
		/*display Hunger refresh:every(1#cycles) {
		    chart "Hunger Means" type: histogram background: #lightgray size: {1,1} position: {0, 0} y_range: {0,150}{
			    data "OTFan" value:  mean (OTFan collect each.hunger) color:#red;
			    data "PrequelsFan" value: mean (PrequelsFan collect each.hunger) color:#cyan;
			    data "DisneySWFan" value: mean (DisneySWFan collect each.hunger) color:#green;
		    }	
		}*/
	}
}
