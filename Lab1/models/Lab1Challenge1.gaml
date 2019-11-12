/***
* Name: Lab1
* Author: Daniel Conde Ortiz and Enrique Perez Soler
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Lab1

global {
	/** Insert the global definitions, variables and actions here */
	init{
		create FestivalGuest number: 10{
			
		}
		
		create Bar number: 2{
			
		}
		
		create FoodTruck number: 2{
			
		}
		
		create InfoPoint number: 1{
			location <- {50,50};
		}
	}
}

species FestivalGuest skills: [moving]{
	point targetPoint <- nil;
	bool hungry <- false;
	bool thirsty <- false;
	rgb color <- #red;
	point infoLoc <- {50,50};
	
	reflex beIdle when: targetPoint = nil{
		do wander;
		
		//random hunger or thirsty
		// maybe better with reflex my_reflex when: flip(0.5) {
		if rnd(100) = 0{
			hungry <- true ;
			color <- #lime;
		}
		else if rnd(100) = 1{
			thirsty <- true ;
			color <- #cyan;
		}
	}
	reflex moveToTarget when: targetPoint != nil{
		do goto target: targetPoint;
	}
	
	reflex goToInfo when: (hungry = true or thirsty = true) and targetPoint = nil{	
		targetPoint <- self.infoLoc;
	}
	
	/**reflex enterStore when: location distance_to(targetPosition) < 2{
		 
	}*/

	reflex enterInfo when: targetPoint != nil and location distance_to(targetPoint) < 1 and targetPoint = self.infoLoc{
	 	if (self.hungry = true){
			ask one_of (FoodTruck){
				myself.targetPoint <- self.location;
			}
		}
		else if (self.thirsty = true){
			ask one_of (Bar){
				myself.targetPoint <- self.location;
			}
		}
	}
	
	reflex enterStore when: targetPoint != nil and (location distance_to(targetPoint) < 1) and (hungry = true or thirsty = true) and targetPoint != self.infoLoc{
	self.hungry <- false;
	self.thirsty <- false;

	self.targetPoint <- {rnd(100),rnd(100)};
	
	self.color <- #red;
	}

	reflex randomPoint when: targetPoint != nil and location distance_to(targetPoint) < 2 and hungry = false and thirsty = false{

	self.targetPoint <- nil;

	}

	
	aspect default{
		draw sphere(2) at: location color: self.color;
	}
	}

species Bar {

	aspect default{
		draw cube(8) at: location color: #blue;
	}
}

species FoodTruck {

	aspect default{
		draw cube(8) at: location color: #green;
	}
}

species InfoPoint {

	aspect default{
		draw cube(8) at: location color: #yellow;
	}

}

experiment Lab1 type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display map type: opengl{
			species FestivalGuest;
			species Bar;
			species FoodTruck;
			species InfoPoint;
		}
	}
}
