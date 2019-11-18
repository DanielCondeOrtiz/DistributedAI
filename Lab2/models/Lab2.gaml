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
		maxi <- rnd(10000);
	}
	
	reflex reply when: (!empty(cfps)){
		message proposalFromInitiatior <- (cfps at 0);
		
		//do propose with: (message: proposalFromInitiatior, contents: ['I will']);
		
		write 'inform initiator of the failure';
		do refuse (message: proposalFromInitiatior, contents: ['The bed is broken']);
	}

	aspect default{
		draw sphere(2) at: location color: #red;
	}
	}

species Auctioneer  skills: [fipa]{
	
	int price;
	bool sold;
	list<FestivalGuest> guests;

	init{
		sold <- false;
		price <- rnd(5000,10000);
		guests <- list(FestivalGuest);
	}

	reflex send_request when: (time=1){
		
			if(sold = true){
				write 'Starting bet again';
				sold <- false;
				price <- rnd(5000,10000);				
			}
			else{
				price <- price - 500;
			}
		
			//inform
			write 'Auctioneer sends inform message to all participants';
			do start_conversation (to:: list(guests), protocol:: 'fipa-contract-net', performative:: 'inform', contents:: ['Auction is beginning']);


			//cfp
			write 'Selling for: ' + string(self.price);
			do start_conversation (to:: list(guests), protocol:: 'fipa-contract-net', performative:: 'cfp', contents:: ['Sell for price ' + self.price, self.price]);

	}

	reflex read_agree_message when: !(empty(proposes)){
		loop p over: proposes{
			write '******' + string(p.sender) + ' buys for ' + string(self.price);
		}
	}
	
	reflex read_failure_message when: !(empty(refuses)){
		loop r over: refuses{
			write '@@@@@' + string(r.sender) + ' rejects ' + string(self.price);
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
