pragma solidity ^0.5.0;

    /*
        The EventTicketsV2 contract keeps track of the details and ticket sales of multiple events.
     */
contract EventTicketsV2 {

    /*
        Define an public owner variable. Set it to the creator of the contract when it is initialized.
    */
    address owner = msg.sender;
    uint   PRICE_TICKET = 100 wei;

    /*
        Create a variable to keep track of the event ID numbers.
    */
    uint public idGenerator = 0;
    uint eventId;

    /*
        Define an Event struct, similar to the V1 of this contract.
        The struct has 6 fields: description, website (URL), totalTickets, sales, buyers, and isOpen.
        Choose the appropriate variable type for each field.
        The "buyers" field should keep track of addresses and how many tickets each buyer purchases.
    */
      struct Event{
        string description;
        string url;
        uint totalTickets;
        uint sales;
        mapping(address => uint) buyers;
        bool isOpen;
    }

    /*
        Create a mapping to keep track of the events.
        The mapping key is an integer, the value is an Event struct.
        Call the mapping "events".
    */
    mapping(uint => Event) events;

    event LogEventAdded(string desc, string url, uint ticketsAvailable, uint eventId);
    event LogBuyTickets(address buyer, uint eventId, uint numTickets);
    event LogGetRefund(address accountRefunded, uint eventId, uint numTickets);
    event LogEndSale(address owner, uint balance, uint eventId);

    /*
        Create a modifier that throws an error if the msg.sender is not the owner.
    */
    modifier isOwner(){
        require(msg.sender == owner, "Not an Owner!");
        _;
    }
    
    /*
        Define a function called addEvent().
        This function takes 3 parameters, an event description, a URL, and a number of tickets.
        Only the contract owner should be able to call this function.
        In the function:
            - Set the description, URL and ticket number in a new event.
            - set the event to open
            - set an event ID
            - increment the ID
            - emit the appropriate event
            - return the event's ID
    */
    function addEvent(string memory _desc, string memory _url, uint _no_of_tickets) isOwner public returns(uint){
        eventId = ++idGenerator;
        events[eventId].description = _desc;
        events[eventId].url = _url;
        events[eventId].totalTickets = _no_of_tickets;
        events[eventId].isOpen = true;
        
        emit LogEventAdded(_desc, _url, _no_of_tickets, eventId);
        return eventId;
    }



    /*
        Define a function called readEvent().
        This function takes one parameter, the event ID.
        The function returns information about the event this order:
            1. description
            2. URL
            3. tickets available
            4. sales
            5. isOpen
    */
    function readEvent(uint _eventId) public view returns(string memory, string memory, uint, uint, bool){
        return (event[_eventId].description, event[_eventId].url, event[_eventId].totalTickets, event[_eventId].sales, event[_eventId].isOpen);
    }

    /*
        Define a function called buyTickets().
        This function allows users to buy tickets for a specific event.
        This function takes 2 parameters, an event ID and a number of tickets.
        The function checks:
            - that the event sales are open
            - that the transaction value is sufficient to purchase the number of tickets
            - that there are enough tickets available to complete the purchase
        The function:
            - increments the purchasers ticket count
            - increments the ticket sale count
            - refunds any surplus value sent
            - emits the appropriate event
    */
     fuction buyTickets(uint _eventid, uint _no_of_tickets) public{
        require(event[_eventId].isOpen == true, "Sales are Closed!");
        require(msg.value >= (_no_of_tickets*PRICE_TICKET), "You don't have enough transaction value to buy tickets.");
        require(events[_eventId].totalTickets >= _no_of_tickets, "There are not many tickets available!");

        events[_eventId].buyer[msg.sender] += _no_of_tickets;
        events[_eventId].totalTickets -= _no_of_tickets;
        events[_eventId].sales++;
        emit LogBuyTickets(msg.sender, _eventId, _no_of_tickets);
    }

    /*
        Define a function called getRefund().
        This function allows users to request a refund for a specific event.
        This function takes one parameter, the event ID.
        TODO:
            - check that a user has purchased tickets for the event
            - remove refunded tickets from the sold count
            - send appropriate value to the refund requester
            - emit the appropriate event
    */
    function getRefund(uint _eventId) public{
        require(events[_eventId].buyer[msg.sender] >= 1, "Record not found for this user.");
        uint numTickets = events[_eventId].buyer[msg.sender];
        msg.value += PRICE_TICKET*numTickets;
        events[_eventId].totalTickets += numTickets;
        events[_eventId].buyer[msg.sender] = 0;
        events[sales] -= numTickets;
        emit LogGetRefund(msg.sender, _eventId, numTickets);
        
    }

    /*
        Define a function called getBuyerNumberTickets()
        This function takes one parameter, an event ID
        This function returns a uint, the number of tickets that the msg.sender has purchased.
    */
    function getBuyerNumberTickets(uint _eventId) public view returns(uint){
        return (events[_eventId].buyer[msg.sender]);

    }

    /*
        Define a function called endSale()
        This function takes one parameter, the event ID
        Only the contract owner can call this function
        TODO:
            - close event sales
            - transfer the balance from those event sales to the contract owner
            - emit the appropriate event
    */
    function endSale(uint _eventId) {
        events[_eventId].isOpen = false;
        uint balance = PRICE_TICKET*events[_eventId].sales;
        msg.value += balance;
        emit LogEndSale(msg.sender, balance, _eventId);

    }
}
