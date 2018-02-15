/**
 * @title Implementation of fractions distribution in ethereum smart-contract
 * @author Maksim Akimov - <merlinkory@yandex.ru>
 */
 
pragma solidity ^0.4.18;

contract distributition{
    
    struct ownerData{
        uint fraction;
        uint nextPayoutIndex;
    }
    struct sellData{
        uint fraction;
        uint price;
    }
    mapping(address=>ownerData) public owners;
    mapping(address=>sellData) public sellingFractions;
    uint[] public transactions;
    
    modifier onlyOwners(){
         require(owners[msg.sender].fraction > 0);
         _;
    }
   
    function distributition() public {
     
        owners[msg.sender].fraction = 100;
        owners[msg.sender].nextPayoutIndex = 0;
    }
    function() public payable{
           
        // Reciving fund  for our contract
        
        transactions.push(msg.value);
    }
    function changeLastTransactionNumber(uint nextPayoutIndex) internal{
        owners[msg.sender].nextPayoutIndex = nextPayoutIndex;
        
    }
    function payout() onlyOwners public{
        require(transactions.length > owners[msg.sender].nextPayoutIndex);
        uint sum = 0;
        uint nextPayoutIndex = owners[msg.sender].nextPayoutIndex;
        
        for(uint i=owners[msg.sender].nextPayoutIndex; i<transactions.length; i++){
            sum += transactions[i]*owners[msg.sender].fraction/100;
            nextPayoutIndex =i+1;
        }
        
        changeLastTransactionNumber(nextPayoutIndex);
        msg.sender.transfer(sum);
     
    }
    
    function sellFraction(uint fraction, uint price)onlyOwners public{
      require(owners[msg.sender].fraction >= fraction);
      sellingFractions[msg.sender].fraction = fraction;
      sellingFractions[msg.sender].price = price;
      
    }
    function buyFraction (address who) public payable{
        require(msg.value == sellingFractions[who].price);
        owners[msg.sender].fraction = sellingFractions[who].fraction;
        owners[msg.sender].nextPayoutIndex = transactions.length;
        owners[who].fraction = owners[who].fraction - sellingFractions[who].fraction;
        who.transfer(sellingFractions[who].price);
        
    }
}
