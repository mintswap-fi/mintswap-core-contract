pragma solidity 0.6.12;

contract OwnableContract {
    address public owner;
    address public pendingOwner;
    address public admin;

    event NewAdmin(address oldAdmin, address newAdmin);
    event NewOwner(address oldOwner, address newOwner);
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    constructor() public {
        owner = msg.sender;
        admin = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "onlyOwner");
        _;
    }

    modifier onlyPendingOwner {
        require(msg.sender == pendingOwner);
        _;
    }

    modifier onlyAdmin {
        require(msg.sender == admin || msg.sender == owner, "onlyAdmin");
        _;
    } 
    
    function transferOwnership(address _pendingOwner) public onlyOwner {
        emit NewPendingAdmin(pendingOwner, _pendingOwner);
        pendingOwner = _pendingOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit NewOwner(owner, address(0));
        emit NewAdmin(admin, address(0));
        emit NewPendingAdmin(pendingOwner, address(0));

        owner = address(0);
        pendingOwner = address(0);
        admin = address(0);
    }
    
    function acceptOwner() public onlyPendingOwner {
        emit NewOwner(owner, pendingOwner);
        owner = pendingOwner;

        address newPendingOwner = address(0);
        emit NewPendingAdmin(pendingOwner, newPendingOwner);
        pendingOwner = newPendingOwner;
    }    
    
    function setAdmin(address newAdmin) public onlyOwner {
        require(newAdmin != address(0), "Ownable: zero address");
        emit NewAdmin(admin, newAdmin);
        admin = newAdmin;
    }
}