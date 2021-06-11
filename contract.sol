pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

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

    function depositBalance(address add,int val) internal{
        account[add].balance = account[add].balance  + val;
    }
     function withdrawBalance(int val) public{
         require(account[msg.sender].balance>0,'No balance' );
        account[msg.sender].balance = account[msg.sender].balance  - val;
    }

    function addFirstUser(address add) internal{
        User memory newuser = User(1,100);
        UserWasteBag memory link = UserWasteBag(0,new uint256[](365));
        userWasteBag[add] = link;
        account[add] = newuser;
        
    }
    function addNewUser(address add) public{
        require(account[msg.sender].auth==1,'Not Authorized');
        User memory user = User(0,50);
        UserWasteBag memory link = UserWasteBag(0,new uint256[](365));
        userWasteBag[add] = link;
        account[add] = user;
    } 
    
    constructor () public{
        addFirstUser(msg.sender);
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

    function addingNewWasteBag(uint256 weight,string memory recyType,string memory timestamp) public{
        Wastebag memory wastebag = 
        Wastebag(
            msg.sender,
            weight,
            recyType,
            timestamp,
            false,
            false,
            'To be picked up'
        );
        wastebags[wasteBagId] = wastebag;
        userWasteBag[msg.sender].array[userWasteBag[msg.sender].lastFIlled++]= wasteBagId;
        emit NewWasteBag(wasteBagId++);
    }
    
    uint256 public lastAuthorized;
    event newAuthorization(
        uint256 indexed lastAuthorized
    );


    function authorizeRequest(bool newStatus,int amount) public{
        require(account[msg.sender].auth==1,'Not Authorized');
        require(lastAuthorized<wasteBagId,'No more bags');
        wastebags[lastAuthorized].status = newStatus;
        wastebags[lastAuthorized].verified = true;
        depositBalance(wastebags[lastAuthorized].useradd,amount);
        emit newAuthorization(lastAuthorized++);
    }
    
    function changeState(string memory location,uint256 id) public{
        require(account[msg.sender].auth==1,'Not Authorized');
        wastebags[id].location = location;
    }

    //Deckare an array of 365 bags and hold the values in it.
     struct UserWasteBag{
       uint256 lastFIlled;
       uint256[] array;
    }
    
    mapping(address=>UserWasteBag) public userWasteBag;
    
   function getMyWasteBagDetails(address add) public view returns (UserWasteBag memory) {
      return userWasteBag[add];
    }
    
    //Conversion functions
    function getWasteBagDetails(string memory s) public view returns (Wastebag memory) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint8 i = 0; i < b.length; i++) { // c = b[i] was not needed
            if (uint8(b[i]) >= 48 && uint8(b[i]) <= 57) {
                result = result * 10 + (uint256(uint8(b[i])) - 48); // bytes and int are not compatible with the operator -.
            }
        }
        Wastebag memory viewWastebag = wastebags[result];
        return viewWastebag; 
    }

}

