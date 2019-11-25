/***
* Name: Lab3chess
* Author: Daniel Conde Ortiz and Enrique Perez Soler
* Description: 
***/

model Lab3chess

global {
	/** Insert the global definitions, variables and actions here */
	
	int N <- 4;
			
	init{	
		create Queen number: N{
			
		}
		
	}
}

species Queen skills: [fipa]{

	list<Queen> queens;
	int order;
	
	chess_board cell;
	
	init{
		queens <- list(Queen);
		cell <- nil;
		location <- {-1,-1,-1};
		order <- int(self);
	}
	
	//Choosing cell
	reflex find_cell when: cell = nil and (order = 0 or queens[order -1].cell != nil){
		bool found <- false;
		int x <- 0;
		int y <- 0;
		
		loop while: found = false{
			
			found <- true;
			loop queen over: queens{
				
				if queen.order >= self.order{
					break;
				}
				
				if queen.cell.grid_x = x or queen.cell.grid_y = y or (queen.cell.grid_x - x = queen.cell.grid_y - y){
					found <- false;
					break;
				}
			}
			
			
			if found = true{
				write self.name + ' found a place! ' + x + ',' + y;
				self.cell <- chess_board[x,y];
				location <- self.cell.location;
			}
			else{
				//Moving one cell right
				x <- x +1;
				if x = N{
					x <- 1;
					y <- y +1;
				}
				
				if y = N{
					break;
				}
			}
		}
		
		//Call for moving
		if found = false{
			write self.name + ' cant find a place, asking Queen ' + string(order-1) + ' to change';
			
			do start_conversation (to:: [self.queens[order-1]], protocol:: 'fipa-request', performative:: 'request', contents:: ['Move please']);
		}
		else if !empty(requests){
			message requestFromInitiator <- (requests at 0);
			
			do agree with: (message: requestFromInitiator, contents: ['New place found!']);
		}

	}
	
	reflex receive_request when: (!empty(requests)){

		bool found <- false;
		int x <- cell.grid_x +1;
		int y <- cell.grid_y;
		
		cell<-nil;
		
		loop while: found = false{
			
			
			if x = N{
				x <- 1;
				y <- y +1;
			}
			
			if y = N{
				break;
			}
			
			
			found <- true;
			loop queen over: queens{
				
				if queen.order >= self.order{
					break;
				}
				
				if queen.cell.grid_x = x or queen.cell.grid_y = y or (queen.cell.grid_x - x = queen.cell.grid_y - y){
					found <- false;
					break;
				}
			}
			
			
			if found = true{
				write self.name + ' found a NEW place! ' + x + ',' + y;
				self.cell <- chess_board[x,y];
				location <- self.cell.location;
			}
			else{
				//Moving one cell right
				x <- x +1;
			}
		}
		
		//Call for moving
		if found = false{
			write self.name + ' cant find a NEW place, asking Queen ' + string(order-1) + ' to change';
			
			do start_conversation (to:: [self.queens[order-1]], protocol:: 'fipa-request', performative:: 'request', contents:: ['Move please']);
		}
		else{
			message requestFromInitiator <- (requests at 0);
			
			do agree with: (message: requestFromInitiator, contents: ['New place found!']);
		}
		
	}
	
	reflex read_agree when: !(empty(agrees)){
		cell <- nil;
		//Goes back to reflex find_cell
	}


	aspect default{
		draw sphere(2) at: location color: #red;
	}
	}


grid chess_board width: N height: N neighbors: 4 {
	    bool occupied <- false;
	    rgb color <- rgb(255*mod(abs(grid_x - grid_y),2), 255*mod(abs(grid_x - grid_y),2), 255*mod(abs(grid_x - grid_y),2));
}

experiment Lab3chess type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		 display main_display{
			grid chess_board lines: #black;
			species Queen;
		}
	}
}
