/***
* Name: Lab3chess
* Author: Daniel Conde Ortiz and Enrique Perez Soler
* Description: 
***/

model Lab3chess

global {
	/** Insert the global definitions, variables and actions here */
	
	int N <- 8;
			
	init{	
		create Queen number: 10{
			
		}
		
	}
}

species Queen skills: [fipa]{

	list<Queen> queens;
	int order;
	
	chess_board cell;
	
	bool waiting_for_reply;
	
	init{
		queens <- list(Queen);
		cell <- nil;
		location <- {-2,-2,-2};
		order <- int(self);
		
		waiting_for_reply <- false;
	}
	
	//Choosing cell
	reflex find_cell when: cell = nil and (order = 0 or queens[order -1].cell != nil) and !waiting_for_reply{
		bool found <- false;
		
		int x <- 0;
		int y <- 0;
		
		if order != 0{
			int x <- queens[order -1].cell.grid_x;
			int y <- queens[order -1].cell.grid_y;
		}

		
		write self.name + ' looking for a place'; 
		
		//loop for searching for cells
		loop while: found = false{
			
			found <- true;
			
			//loop for checking predecessing queens' position
			loop queen over: queens{
				
				//If actual queen I'm checking goes before me or is me -> BREAK
				if queen.order >= self.order{
					break;
				}//queen is not me and it goes before me
				
				//If my position (x or y) collides with any of the preconditions -> BREAKS
				if x = queen.cell.grid_x or y <= queen.cell.grid_y or (abs(x - queen.cell.grid_x) = abs(y - queen.cell.grid_y)){
					found <- false;
					break;
				}//VALID POSITION
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
					x <- 0;
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
			
			waiting_for_reply <- true;
		}
		else if !empty(requests){
			message requestFromInitiator <- (requests at 0);
			
			do agree with: (message: requestFromInitiator, contents: ['New place found!']);
		}

	}
	
	reflex receive_request when: (!empty(requests)) and cell != nil and !waiting_for_reply{

		bool found <- false;
		int x <- cell.grid_x +1;
		int y <- cell.grid_y;

		write self.name + ' looking for a NEW place'; 
		
		cell<-nil;
		
		loop while: found = false{	
			
			if x = N{
				x <- 0;
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
				
				if queen.cell.grid_x = x or queen.cell.grid_y >= y or (abs(x - queen.cell.grid_x) = abs(y - queen.cell.grid_y)){
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
			
			waiting_for_reply <- true;
			
		}
		else{
			message requestFromInitiator <- (requests at 0);
			
			do agree with: (message: requestFromInitiator, contents: ['New place found!']);
		}
		
	}
	
	reflex read_agree when: !(empty(agrees)){
		cell <- nil;
		location <- {-10,-10,-10};
		waiting_for_reply <- false;
		
		loop a over: agrees{
			int tmp<- int(a.contents);
			write self.name + ' message received from ' + agent(a.sender).name; 
		}
		
		//Goes back to reflex find_cell
	}


	aspect default{
		draw sphere(3) at: location color: #red;
		draw '' + self.order at: location + {-0.8,0.8} color: #black font: font('Default', 22, #bold) ;
	}
	}


grid chess_board width: N height: N neighbors: 4 {
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
