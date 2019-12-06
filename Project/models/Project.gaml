/***
* Name: Project
* Author: Daniel Conde Ortiz and Enrique Perez Soler
* Description: Star Wars fair
***/

model Project

global {
	//Creation of agents
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

	//Variables
	//Preferences for types
	float OTPref;
	float PreqPref;
	float DisneyPref;
	
	//Current show
	float scoreCurrentShow;
	Stage currentShow;
	
	float happiness;
	
	//Variables to interact with others
	float noiseResistance;
	float generous;
	int justBought;
	
	bool smokes;
	
	//Son
	DisneySWFan child;
	
	//Related to eating
	int hunger;
	bool needToEat;
	point cantineLocation;
	
	//Related to moving and surrounding
	point targetPoint;
	float maxDistancePoint;
	float maxDistanceRadius;
	
	bool previouslyChecked;


	//Initialization
	init{

		OTPref<- 10.0;
		PreqPref<- rnd(0,5)/10;
		DisneyPref<- rnd(0,3)/10;
		
		scoreCurrentShow<-0.0;
		currentShow<-nil;
		
		happiness<-0.0;

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
	
	
	//Drops 1 hunger point (0.8 probable)
	reflex get_hungry when: hunger > 0{
		if flip(0.8){
			hunger<- hunger - 1;
		}
		
		if hunger = 0{
			targetPoint<-cantineLocation;
			needToEat <- true;
			
			scoreCurrentShow<-0.0;
			currentShow<-nil;
		}
	}
	
	
	//When in cantine, fills hunger by 10 and leaves when full or too many Disney Fans
	//Also decreases the buying parameter
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
	
	//Replies to people asking to buy drinks
	reflex replyBuy when: (!empty(cfps)){
		loop c over: cfps{
			message requestFromInitiator <- c;
						
			string tmp<-string(c.contents);
			
			if flip(generous) and justBought < generous*10{
				
				justBought<- justBought+1;
				
				do propose message: requestFromInitiator contents: ['Okay!',true];
			
			}else{
				
				do propose message: requestFromInitiator contents: ['No, sorry',false];
			}
		}
	}
	
	//Reads messages from stages when a new show begins
	reflex read_informs when: !(empty(informs)){
		loop i over: informs{

			float score;
			
			if i.contents[1] = 1{
				score<-OTPref;
			}else if i.contents[1] = 2{
				score<-PreqPref;
			}else{
				score<-DisneyPref;
			}
			
			if score > scoreCurrentShow and !needToEat{
				currentShow<-i.sender;
				targetPoint<-currentShow.location;
				scoreCurrentShow<-score;
			}
			
		}
	}
	
	//Reads proposals from stages
	reflex read_proposes when: !(empty(proposes)){
		loop p over: proposes{

			float score;
			
			if p.contents[1] = 1{
				score<-OTPref;
			}else if p.contents[1] = 2{
				score<-PreqPref;
			}else{
				score<-DisneyPref;
			}
			
			if score > scoreCurrentShow and !needToEat{
				currentShow<-p.sender;
				targetPoint<-currentShow.location;
				scoreCurrentShow<-score;
			}
		
		}
	}
	
	//Chooses where to go next
	reflex choosePlace when: targetPoint = nil{
		
		//0.1 probability to go to a random place
		if flip(0.1){
			targetPoint <- {rnd(100),rnd(100)};
		}else{
			do start_conversation (to:: list(Stage), protocol:: 'fipa-contract-net', performative:: 'cfp', contents:: ['What is the show?']);
		}
	}
	
	//Goes to selected point and stops if close
	reflex goToDest when: targetPoint != nil{
		if location distance_to(targetPoint) > maxDistancePoint{
			do goto target: targetPoint;	
		}else{
			do wander speed: 0.1;
		}
		
	}
	
	aspect default{
		draw sphere(2) at: location color: #red;
		//draw circle(maxDistanceRadius) at: location color: #black;
		
	}
}


species PrequelsFan skills: [fipa,moving]{
	
	//Variables
	//Preferences for types
	float OTPref;
	float PreqPref;
	float DisneyPref;
	
	//Current show
	float scoreCurrentShow;
	Stage currentShow;
	
	float happiness;
	
	//Variables to interact with others
	float noiseResistance;
	bool alreadyAsked;
	int agreesNum;

	//Related to eating
	int hunger;
	bool needToEat;
	point cantineLocation;

	//Related to moving and surrounding
	point targetPoint;
	float maxDistancePoint;
	float maxDistanceRadius;

	//Initialization
	init{

		OTPref<- rnd(7,9)/10;
		PreqPref<- rnd(7,10)/10;
		DisneyPref<- rnd(0,5)/10;
		
		scoreCurrentShow<-0.0;
		currentShow<-nil;
		
		happiness<-0.0;
		
		noiseResistance <- rnd(10)/10;
		alreadyAsked<-false;
		agreesNum<-0;
		
		hunger <- rnd(200,250);
		needToEat <- false;
		ask Cantine{
			myself.cantineLocation <- self.location;
		}
		
		targetPoint <- nil;
		maxDistancePoint<-6.0;
		maxDistanceRadius<-10.0;

	}
	
	//Drops 1 hunger point (0.8 probable)
	reflex get_hungry when: hunger > 0{
		if flip(0.8){
			hunger<- hunger - 1;
		}
		
		if hunger = 0{
			targetPoint<-cantineLocation;
			needToEat <- true;
			
			scoreCurrentShow<-0.0;
			currentShow<-nil;
		}
	}
	
	
	//When in cantine, fills hunger by 10 and leaves when full
	//Also, asks OTFans for buying drinks
	reflex eating when: needToEat and location distance_to(cantineLocation) <= maxDistancePoint {
		hunger <- hunger + 10;
		
		if hunger > 200 and flip(0.8){
			needToEat<- false;
			targetPoint<-nil;		
			alreadyAsked<-false;	
		}
		
		
		if !alreadyAsked and length( agents_at_distance(maxDistanceRadius) of_species (OTFan)) >0{
			//request to buy
			write self.name + ' asking OTFans if buying a drink';
			do start_conversation (to:: list(agents_at_distance(maxDistanceRadius) of_species (OTFan)), protocol:: 'fipa-contract-net', performative:: 'cfp', contents:: ['Buy drink?']);
		
			alreadyAsked<-true;
			agreesNum<-0;
		}
	}
	
	//Reads replies proposing to buy or not from OTFans or
	//proposals from stages
	reflex read_proposes when: !(empty(proposes)){
		loop p over: proposes{
			if species(p.sender) = Stage{
				float score;
				
				if p.contents[1] = 1{
					score<-OTPref;
				}else if p.contents[1] = 2{
					score<-PreqPref;
				}else{
					score<-DisneyPref;
				}
				
				if score > scoreCurrentShow and !needToEat{
					currentShow<-p.sender;
					targetPoint<-currentShow.location;
					scoreCurrentShow<-score;
				}
			}else{
				//Agrees
				if bool(p.contents[1]){
					do accept_proposal (message: p, contents: ['Great!']);
					agreesNum<- agreesNum + 1;
					
					//Calls for more
					if agreesNum > length(agents_at_distance(maxDistanceRadius) of_species (PrequelsFan) ){
						write self.name + ' calls for more people';
						do start_conversation (to:: [one_of(list(PrequelsFan) - agents_at_distance(maxDistanceRadius) of_species (PrequelsFan))], protocol:: 'fipa-contract-net', performative:: 'inform', contents:: ['Someone is buying drinks']);
					}	
				}
				
				//Rejects
				else{
					do reject_proposal (message: p, contents: ['No problem!']);
				}
			
			}
		}
	}
	
	//Reads messages from other PrequelsFans saying that someone is buying drinks
	//or from stages when a new show begins
	reflex read_informs when: !(empty(informs)){
		loop i over: informs{
			
			//Someone is buying drinks
			if species(i.sender) = PrequelsFan{
				
				string tmp <- string(i.contents);
			
				write self.name + ' going for drinks!';
				targetPoint <-cantineLocation;
			}
			
			//New show
			else{
				float score;
				
				if i.contents[1] = 1{
					score<-OTPref;
				}else if i.contents[1] = 2{
					score<-PreqPref;
				}else{
					score<-DisneyPref;
				}
				
				if score > scoreCurrentShow and !needToEat{
					currentShow<-i.sender;
					targetPoint<-currentShow.location;
					scoreCurrentShow<-score;
				}
			}
			
		}
	}

	
	//Chooses where to go next
	reflex choosePlace when: targetPoint = nil{
		//0.1 probability to go to a random place
		if flip(0.1){
			targetPoint <- {rnd(100),rnd(100)};
		}else{
			do start_conversation (to:: list(Stage), protocol:: 'fipa-contract-net', performative:: 'cfp', contents:: ['What is the show?']);
		}
	}
	
	//Goes to selected point and stops if close
	reflex goToDest when: targetPoint != nil{

		if location distance_to(targetPoint) > maxDistancePoint{
			do goto target: targetPoint;	
		}else{
			do wander speed: 0.1;
		}
		
	}

	aspect default{
		draw sphere(2) at: location color: #cyan;
	}
}

species DisneySWFan skills: [fipa,moving]{

	//Variables
	//Preferences for types
	float OTPref;
	float PreqPref;
	float DisneyPref;
	
	//Current show
	float scoreCurrentShow;
	Stage currentShow;
	
	float happiness;
	
	//Variables to interact with others
	float noisy;
	OTFan parent;
	bool previouslyChecked;

	//Related to eating
	int hunger;
	bool needToEat;
	point cantineLocation;

	//Related to moving and surrounding
	point targetPoint;
	float maxDistancePoint;
	float maxDistanceRadius;
	

	//Initialization
	init{

		OTPref<- rnd(5,8)/10;
		PreqPref<- rnd(5,10)/10;
		DisneyPref<- rnd(7,10)/10;
		
		scoreCurrentShow<-0.0;
		currentShow<-nil;
		
		happiness<-0.0;
		
		noisy <- rnd(10)/10;
		parent <- nil;
		previouslyChecked<-false;
		
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
		
	}
	
	//Drops 1 hunger point (0.8 probable)
	reflex get_hungry when: hunger > 0{
		if flip(0.8){
			hunger<- hunger - 1;
		}
		
		if hunger = 0{
			targetPoint<-cantineLocation;
			needToEat <- true;
			
			scoreCurrentShow<-0.0;
			currentShow<-nil;
		}
	}
	
	//When in cantine, fills hunger by 10 and leaves when full or too many PrequelsFan in the cantine
	reflex eating when: needToEat and location distance_to(cantineLocation) <= maxDistancePoint + 0.1{
		hunger <- hunger + 10;
		
		if hunger > 200 and flip(0.8){
			needToEat<- false;
			targetPoint<-nil;
			
			previouslyChecked<-false;	
		}
		 
		//Leaves if too many PrequelsFan eating in the same place
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
	
	//Reads messages from stages when a new show begins
	reflex read_informs when: !(empty(informs)){
		loop i over: informs{

			float score;
			
			if i.contents[1] = 1{
				score<-OTPref;
			}else if i.contents[1] = 2{
				score<-PreqPref;
			}else{
				score<-DisneyPref;
			}
			
			if score > scoreCurrentShow and !needToEat{
				currentShow<-i.sender;
				targetPoint<-currentShow.location;
				scoreCurrentShow<-score;
			}
			
		}
	}
	
	//Reads proposals from stages
	reflex read_proposes when: !(empty(proposes)){
		loop p over: proposes{

			float score;
			
			if p.contents[1] = 1{
				score<-OTPref;
			}else if p.contents[1] = 2{
				score<-PreqPref;
			}else{
				score<-DisneyPref;
			}
			
			if score > scoreCurrentShow and !needToEat{
				currentShow<-p.sender;
				targetPoint<-currentShow.location;
				scoreCurrentShow<-score;
			}
		
		}
	}
	
	//Chooses where to go next
	reflex choosePlace when: targetPoint = nil{
		//0.1 probability to go to a random place
		if flip(0.1){
			targetPoint <- {rnd(100),rnd(100)};
		}else{
			do start_conversation (to:: list(Stage), protocol:: 'fipa-contract-net', performative:: 'cfp', contents:: ['What is the show?']);
		}
	}
		
	//Goes to selected point and stops if close
	reflex goToDest when: targetPoint != nil{


		if location distance_to(targetPoint) > maxDistancePoint{
			do goto target: targetPoint;	
		}else{
			do wander speed: 0.1;
		}
		
	}
	

	aspect default{
		draw sphere(2) at: location color: #green;
		//draw 'D' at: location + {-0.8,0.8,5} color: #black font: font('Default', 20, #bold) ;
		
	}
}


species Cantine {

	//Initialization
	init{
		location <- {0,50,0};
	}
	
	
	aspect default{
		draw cube(7) at: location color: #green;
	}
}


species Stage skills: [fipa]{

	//Variables
	int order;

	// 1 = OT
	// 2 = Preq
	// 3 = Disney
	int currentShow;

	int showTime;

	//Initialization
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
		currentShow <- rnd (1,3);
		
		showTime <-0;
	}
	
	//Generates a new concert and sends an inform message to all the people
	reflex new_show when: showTime = 0{
		showTime<-rnd(100,300);
		
		// 1 = OT
		// 2 = Preq
		// 3 = Disney
		currentShow <- rnd (1,3);
		
		write self.name + ' new show! Type: ' + currentShow;
		
		do start_conversation (to:: list(OTFan), protocol:: 'fipa-contract-net', performative:: 'inform', contents:: ['New show!',currentShow,showTime]);
		do start_conversation (to:: list(PrequelsFan), protocol:: 'fipa-contract-net', performative:: 'inform', contents:: ['New show!',currentShow,showTime]);	
		do start_conversation (to:: list(DisneySWFan), protocol:: 'fipa-contract-net', performative:: 'inform', contents:: ['New show!',currentShow,showTime]);
	}
	
	//Decreases the show time by one at a time
	reflex decrease_time when: showTime > 0{
		showTime<- showTime-1;
	}
	
	//Replies to people asking about the shows
	reflex replyBuy when: (!empty(cfps)){
		loop c over: cfps{
			message requestFromInitiator <- c;
						
			string tmp<-string(c.contents);
				
			do propose message: requestFromInitiator contents: ['Current show: ',currentShow,showTime];
		}
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
