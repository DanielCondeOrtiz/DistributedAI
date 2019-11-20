/***
* Name: Lab2
* Author: Daniel Conde Ortiz and Enrique Perez Soler
* Description: 
***/

model Lab2

global {
	/** Insert the global definitions, variables and actions here */
	init{
		create FestivalGuest number: 3{
			
		}
		
		create Auctioneer number: 1{
			
		}
		
	}
}

species FestivalGuest skills: [fipa]{

	int maxi;
	
	init{
		maxi <- rnd(8000);
	}
	
	reflex reply when: (!empty(cfps)){
		message proposalFromInitiatior <- (cfps at 0);
		
		
		if(int(proposalFromInitiatior.contents[1]) < maxi){
			write 'A';
			do propose with: (message: proposalFromInitiatior, contents: ['I buy for ' + maxi]);
		}
		else{
			write 'B';
			do refuse (message: proposalFromInitiatior, contents: ['I reject beca']);
			
		}
		
	}

	aspect default{
		draw sphere(2) at: location color: #red;
	}
	}

species Auctioneer  skills: [fipa]{
	
	int price;
	bool sold;
	list<FestivalGuest> guests;
	int counter;
	int minimum;

	init{
		sold <- false;
		price <- rnd(5000,10000);
		guests <- list(FestivalGuest);
		counter <-3;
		minimum <- 4000;
	}

	reflex send_request when: counter = length(guests) and mod(time,10) = 0{
		
			if(sold = true){
				write 'Starting bet again';
				sold <- false;
				price <- rnd(5000,10000);				
			}
			else{
				price <- price - 500;
			}
		
			counter <- 0;
		
			//inform
			write 'Auctioneer sends inform message to all participants';
			do start_conversation (to:: list(guests), protocol:: 'fipa-contract-net', performative:: 'inform', contents:: ['Auction is beginning']);


			//cfp
			write 'Selling for: ' + string(self.price);
			do start_conversation (to:: list(guests), protocol:: 'fipa-contract-net', performative:: 'cfp', contents:: ['Sell for price ' + self.price, self.price]);

	}

	reflex read_agree_message when: !(empty(proposes)){
		loop p over: proposes{
			counter <- counter + 1;
			
			write '******' + string(p.sender) + ' buys for ' + string(self.price);
			do accept_proposal (message: p, contents: ['Sold!']);
			sold<- true;
		}
	}
	
	reflex read_failure_message when: !(empty(refuses)){
		loop r over: refuses{
			counter <- counter + 1;
			
			write '@@@@@' + string(r.sender) + ' rejects ' + string(self.price);
			do reject_proposal (message: r, contents: ['Bye']);
		}
	}

	aspect default{
		draw cube(8) at: location color: #blue;
	}
}



experiment Lab2 type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display map type: opengl{
			species FestivalGuest;
			species Auctioneer;
		}
	}
}
