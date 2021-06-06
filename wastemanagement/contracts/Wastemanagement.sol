pragma solidity ^0.5.16;



contract Wastemanagement {
    
     struct User{
        uint256 auth; //1 high level- Allowed to do transaction,2 - Updates the location to the user, 3- normal user.  
        int balance;
    }
   
    address internal userAddress;
    mapping(address => User) public account;
    
    function getBalance (address add) public view returns (int) {
        return account[add].balance;
    }

   function depositBalance(address add,int val) public{
        account[add].balance = account[add].balance  + val;
    }

    function addFirstUser(address add) internal{
        User memory newuser = User(1,100);
        account[add] = newuser;
        
    }
    function addNewUser(address add) public{
        require(account[msg.sender].auth==1,'Not Authorized');
        User memory user = User(0,50);
        account[add] = user;
    } 
    
    constructor () public{
        addFirstUser(msg.sender);
        addNewWasteBag(2,'plastic','20-2-2020','Reached recycling station');
        addNewWasteBag(3,'metal','20-2-2020','Recycled');
    }
    
    struct Wastebag{
        address useradd;
        uint256 weight;
        string recyType; //glass/metal/plastic/paper/organic
        string timestamp;
        bool status; //accepted,rejected
        bool verified;
        string location;
    }
 
    uint256 public wasteBagId;
    mapping(uint256 => Wastebag) public wastebags;
    event NewWasteBag(
        uint256 indexed wasteBagId
    );

    function addNewWasteBag(uint256 weight,string memory recyType,string memory timestamp,string memory location) public{
        Wastebag memory wastebag = 
        Wastebag(
            msg.sender,
            weight,
            recyType,
            timestamp,
            false,
            false,
            location
        );
        wastebags[wasteBagId] = wastebag;
        emit NewWasteBag(wasteBagId++);
    }
    
    uint256 public lastAuthorized;
    event newAuthorization(
        uint256 indexed lastAuthorized
    );


    function authorizeRequest(bool newStatus,int amount) public{
        require(account[msg.sender].auth==1,'Not Authorized');
        wastebags[lastAuthorized].status = newStatus;
        wastebags[lastAuthorized].verified = true;
        depositBalance(wastebags[lastAuthorized].useradd,amount);
        emit newAuthorization(lastAuthorized++);
    }

}
