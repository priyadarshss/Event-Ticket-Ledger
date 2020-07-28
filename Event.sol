pragma solidity ^0.6.10;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

contract EventContract 
{
  mapping(uint => Events) public Event;
  mapping(address => mapping(uint => uint)) public Tickets;
  uint nextId;
  string[] private array;
  uint event_cost=1 wei;  
  
  struct Events 
  {
    address admin;
    string name;
    uint date;
    uint price;
    uint ticketRemaining;
    uint ticketCount;
  }
  

  modifier eventExist(uint id) 
    {
    require(Event[id].date != 0, 'This event does not exist');
    _;
    }
  modifier eventActive(uint id) 
    {
    require(now < Event[id].date, 'Event ticket buying time has expired.');
    _;
    }


  function Create_Event
    (
    string calldata name,
    uint date,
    uint price,
    uint ticketCount
    ) 
    external payable 
    {
    require(date > now, 'Can only organize event at a future date');
    require(ticketCount > 0, 'Can only organize event with at least 1 ticket.');
    require(msg.value==1 wei, 'Can create event only if 1 Ether is sent.');
    array.push(name);
    Event[nextId] = Events(
      msg.sender, 
      name, 
      date, 
      price, 
      ticketCount,
      ticketCount
    );
    nextId++;
  }


  function Buy_Ticket(uint id, uint quantity) 
    eventExist(id) 
    eventActive(id)
    payable
    external 
    {
    Events storage _event = Event[id];
    require(msg.value == (_event.price * quantity), 'Ether sent must be equal to total ticket cost'); 
    require(_event.ticketRemaining >= quantity, 'Not enough ticket left');
    _event.ticketRemaining -= quantity;
    Tickets[msg.sender][id] += quantity;
    }


  function Transfer_Ticket(uint eventId, uint quantity, address to) 
    eventExist(eventId)
    eventActive(eventId)
    external 
    {
      require(Tickets[msg.sender][eventId] >= quantity, 'Not enough ticket');
      Tickets[msg.sender][eventId] -= quantity;
      Tickets[to][eventId] += quantity;
    }
    

  function Show_Events() 
    public view returns 
    (string[] memory) 
    {
        return array;
    }
}
