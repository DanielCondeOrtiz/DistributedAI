/***
* Name: Lab1
* Author: Daniel Conde Ortiz and Enrique Perez Soler
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Lab1

global {
	/** Insert the global definitions, variables and actions here */
}

species FestivalGuest skills: [moving]{
	point targetPoint <- nil;
	reflex beIdle when: targetPoint = nil{
		do wander;
	}
	reflex moveToTarget when: targetPoint != nil{
		do goto target: targetPoint;
	}
	/**reflex enterStore when: location distance_to(targetPosition) < 2{
		 
	}*/
}

experiment Lab1 type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
	}
}
