pragma solidity >=0.4.21 <0.6.0;


contract ticketingSystem {

	//_________________________________________________________________
	//_________________________STRUCTURES______________________________

	struct Artist {
		bytes32 name;
		uint artistCategory;
		address payable owner;
		uint totalTicketSold;
	}
	
	struct Venue {
		bytes32 name;
		uint capacity;
		uint standardComission;
		address payable owner;
	}
	
	struct Concert {
		uint artistId;
		uint concertDate;
		uint venueId;
		bool validatedByArtist;
		bool validatedByVenue;
		uint totalSoldTicket;
		uint totalMoneyCollected;
		uint ticketPrice;
	}
	
	struct Ticket {
		uint concertId;
		uint amountPaid;
		bool isAvailable;
		address payable owner;
		bool isAvailableForSale;
		uint numTicket;   
		uint salePrice;
	}
	
	//__________________________________________________________________
	//_________________________MAPPINGS_________________________________
	
	mapping(uint => Artist) public artistsRegister;
	mapping(uint => Venue) public venuesRegister;
	mapping(uint => Concert) public concertsRegister;
	mapping(uint => Ticket) public ticketsRegister;
	
	//__________________________________________________________________
	//_________________________DECLARATION______________________________
	
	uint public nextIdArtist;
	uint public nextIdVenue;
	uint public nextIdConcert;
	uint public nextIdTicket;
	
	constructor() public {
		nextIdArtist = 1;
		nextIdVenue = 1;
		nextIdConcert = 1;
		nextIdTicket = 1;
	}
	
	//___________________________________________________________________
	//_________________________FUNCTIONS CREATE__________________________
	
	
	function createArtist(bytes32 _name, uint _artistCategory) public returns(uint numArtist) {
	// Create function to create an artist profile
	
		require(_name != 0x0);
		//0x0 est une abréviation pour l'adresse de la genèse 0x(40 zéros). 
		//0x0 un trou noir d'une adresse. Les fonds éthers entrent, mais aucun ne sort.
		//require équivalent à un if		
		//recommandé d’utiliser require en début de fonction, notamment pour tous les tests sur les variables entrées par les utilisateurs.
		
		artistsRegister[nextIdArtist].name = _name;
		artistsRegister[nextIdArtist].artistCategory = _artistCategory;
		artistsRegister[nextIdArtist].owner = msg.sender;
		// msg.sender est la personne qui se connecte actuellement au contrat
		
		numArtist = nextIdArtist;
		nextIdArtist +=1; 
	}
	
	function createVenue(bytes32 _name, uint _capacity, uint _standardComission) public returns(uint numVenue) {
	//Create function to create a venue profile
	
		require(_name != 0x0); 
		venuesRegister[nextIdVenue].name = _name;
		venuesRegister[nextIdVenue].capacity = _capacity;
		venuesRegister[nextIdVenue].standardComission= _standardComission;
		venuesRegister[nextIdVenue].owner = msg.sender;
		numVenue = nextIdVenue;
		nextIdVenue +=1;
	}
	
	function createConcert(uint _artistId, uint _venueId, uint _concertDate, uint _ticketPrice) public returns(uint numConcert) {
		require(_concertDate >= now);
		// now = horodatage du bloc actuel (alias pour block.timestamp)
		
		concertsRegister[nextIdConcert].artistId = _artistId;
		concertsRegister[nextIdConcert].venueId = _venueId;
		concertsRegister[nextIdConcert].concertDate = _concertDate;
		concertsRegister[nextIdConcert].ticketPrice = _ticketPrice;
		validateConcert(nextIdConcert);
		numConcert = nextIdConcert;
		nextIdConcert +=1;
	}
	
	function emitTicket(uint _concertId, address payable _ticketOwner) public returns(uint numTicket) {
	//Create function to emit tickets
	
		require(artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender);
		//Artists can emit tickets that they own
		
		ticketsRegister[nextIdTicket].concertId = _concertId;
		ticketsRegister[nextIdTicket].owner = _ticketOwner;
		concertsRegister[_concertId].totalSoldTicket += 1;
		ticketsRegister[nextIdTicket].isAvailable = true;
		numTicket = nextIdTicket;
		nextIdTicket +=1;	
	}
	
	//___________________________________________________________________
	//_________________________FUNCTIONS MODIFY__________________________
		
	function modifyArtist(uint _artistId, bytes32 _name, uint _artistCategory, address payable _newOwner) public {
	// Create function to modify an artist profile
	
		require(_name != 0x0);
		require(artistsRegister[_artistId].owner == msg.sender);
		artistsRegister[_artistId].name = _name;
		artistsRegister[_artistId].artistCategory = _artistCategory;
		artistsRegister[_artistId].owner = _newOwner;	
	}
	
	function modifyVenue(uint _venueId, bytes32 _name, uint _capacity, uint _standardComission, address payable _newOwner) public {
	// Create function to modify a venue profile
	
		require(_name != 0x0);
		require(venuesRegister[_venueId].owner == msg.sender);
		venuesRegister[_venueId].name = _name;
		venuesRegister[_venueId].capacity = _capacity;
		venuesRegister[_venueId].standardComission = _standardComission;
		venuesRegister[_venueId].owner = _newOwner;
	}
	
	//___________________________________________________________________
	//___________________FUNCTIONS RELATED TO CONCERT____________________
	
	function validateConcert(uint _concertId) public {
	// Before happening, a concert needs to be validated/confirmed by the artist and the venue
	
		require(concertsRegister[_concertId].concertDate >= now);
		if(artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender){
			concertsRegister[_concertId].validatedByArtist = true; }
		if(venuesRegister[concertsRegister[_concertId].venueId].owner == msg.sender){
			concertsRegister[_concertId].validatedByVenue = true; }
	}
		
	//___________________________________________________________________
	//___________________FUNCTIONS RELATED TO TICKET_____________________
	
	function useTicket(uint _ticketId) public {
	//Create function to use tickets
	
		require(ticketsRegister[_ticketId].owner == msg.sender);
		
		require(concertsRegister[ticketsRegister[_ticketId].concertId].concertDate > now);
		require(concertsRegister[ticketsRegister[_ticketId].concertId].concertDate < now + 86400); 
		// Ticket owner can use tickets in the 24h before the concert
		// Attention : Exprimer le temps en secondes 
		// now + 1jour ; 1jour = 60sec * 60min * 24h = 86400sec
		
		require(concertsRegister[ticketsRegister[_ticketId].concertId].validatedByArtist);
		require(concertsRegister[ticketsRegister[_ticketId].concertId].validatedByVenue);
		
		delete ticketsRegister[_ticketId];
	}
	
	function buyTicket(uint _concertId) public payable returns(uint numTicket) {
	//Create function to buy tickets	
		require(venuesRegister[concertsRegister[_concertId].venueId].capacity >= concertsRegister[_concertId].totalSoldTicket);
		require(concertsRegister[_concertId].concertDate > now);
				
		ticketsRegister[nextIdTicket].concertId = _concertId;
		ticketsRegister[nextIdTicket].owner = msg.sender;
		concertsRegister[_concertId].totalSoldTicket += 1;
		ticketsRegister[nextIdTicket].isAvailable = true;
		concertsRegister[_concertId].totalMoneyCollected += msg.value; // msg.value contient la quantité de wei (ether / 1e18) envoyée dans la transaction.
		ticketsRegister[_concertId].amountPaid = msg.value;
		numTicket = nextIdTicket;
		nextIdTicket +=1;	
	}

	function transferTicket(uint _ticketId, address payable _newOwner) public {
	//Create function to transfer tickets
	
		require(ticketsRegister[_ticketId].owner == msg.sender);
		require(concertsRegister[ticketsRegister[_ticketId].concertId].concertDate > now);
		ticketsRegister[_ticketId].owner = _newOwner;
	}
		
	//function cashOutConcert(uint _concertId, address payable _addressForCashOut) public {
	// Create a function for the artist to cash out after the concert
	
		//require(concertsRegister[_concertId].concertDate < now);
		//Make sure the concert has passed
		
		//require(artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender);
		
		//Split the money between artist and venue	
		// uint finalAmountVenue = concertsRegister[_concertId].totalMoneyCollected*venuesRegister[concertsRegister[_concertId].venueId].standardComission/10000;
		// Montant final perçu par le lieu = total de l'argent gagné grâce au concert * le prix de la commision du lieu/10000
		// Attention : La commission est enregistrée en pourcentage avec 2 décimales (05_ConcertCashOut) => /10000
		
		//uint finalAmountArtist = concertsRegister[_concertId].totalMoneyCollected - finalAmountVenue;
		// Montant final perçu par l'artiste = total de l'argent gagné grâce au concert - le montant final payé pour le lieu 
				
	//}

	function offerTicketForSale(uint _ticketId, uint _salePrice) public {
	// Create a function to safely trade ticket for money 
	
		require(ticketsRegister[_ticketId].owner == msg.sender);
		
		require(concertsRegister[ticketsRegister[_ticketId].concertId].ticketPrice > _salePrice);
		// Forbid selling the ticket for more than it was bought
			
		ticketsRegister[_ticketId].salePrice = _salePrice;
		ticketsRegister[_ticketId].isAvailableForSale = true;
	}
	
	function buySecondHandTicket(uint _ticketId) public payable {
	//Create a function to redeem distributed tickets
		require(ticketsRegister[_ticketId].isAvailableForSale);
		require(ticketsRegister[_ticketId].salePrice == msg.value);
		
		ticketsRegister[_ticketId].isAvailableForSale = false;
		//Tickets can be created but not sold
		
		ticketsRegister[_ticketId].owner.transfer(msg.value);
		//Users must be able to redeem their tickets with a chain of characters
		
		ticketsRegister[_ticketId].owner = msg.sender;
	}

}