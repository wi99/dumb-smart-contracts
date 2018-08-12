pragma solidity ^0.4.7;

contract StringBounty {
    
    // why even use events
    event B(bytes32 hash, address addr, uint reward);
    event S(bytes32 hash, string thing);
    
    struct Bounty {
        address addr;
        string stringThing;
        uint reward;
    }
    mapping (bytes32 => Bounty) Bounties;

    constructor() public {
    }

    function postBounty(bytes32 _hash) external payable{
        require(msg.value > 0); // must have reward
        require(keccak256(abi.encodePacked(Bounties[_hash].stringThing)) == keccak256(abi.encodePacked('')));
        if(Bounties[_hash].reward > 0){
            require(msg.value > Bounties[_hash].reward); // change only if amount is more
            Bounties[_hash].addr.transfer(Bounties[_hash].reward); // and refund old addr
        }
        Bounties[_hash] = Bounty(msg.sender, '', msg.value);
        emit B(_hash, msg.sender, msg.value);
    }

    /**
     * Letting a user have a refund whenever they want is no fun
     * So make sure to delete this when deploying the contract.
     * @param _hash the hash
     * @param _amount the amount to subtract from the bounty.
    **/
    function reduceBountyReward(bytes32 _hash, uint _amount) external{
        require(Bounties[_hash].addr == msg.sender); // must be same address that made bounty
        require(keccak256(abi.encodePacked(Bounties[_hash].stringThing)) != _hash); // must be not already done
        require(Bounties[_hash].reward > _amount); // _amount must be less than reward
        Bounties[_hash].reward -= _amount;
        msg.sender.transfer(_amount);
        emit B(_hash, msg.sender, Bounties[_hash].reward);
    }
    
    function giveStringGetMoney(string _thing) external{
        require(keccak256(abi.encodePacked(Bounties[keccak256(abi.encodePacked(_thing))].stringThing)) != keccak256(abi.encodePacked(_thing))); // must not be already done
        require(Bounties[keccak256(abi.encodePacked(_thing))].reward > 0); // check if there is reward (this will always pass because I did > instead of >= in _amount must be less than reward)
        Bounties[keccak256(abi.encodePacked(_thing))].stringThing = _thing;
        emit S(keccak256(abi.encodePacked(_thing)), _thing);
        msg.sender.transfer(Bounties[keccak256(abi.encodePacked(_thing))].reward);
        Bounties[keccak256(abi.encodePacked(_thing))].reward = 0;
    }
    
    // should these have events, do I even want these functions?
    function getBountyAddress(bytes32 _hash) external view returns (address){
        return Bounties[_hash].addr;
    }
    function getBountyString(bytes32 _hash) external view returns (string){
        return Bounties[_hash].stringThing;
    }
    function getBountyReward(bytes32 _hash) external view returns (uint){
        return Bounties[_hash].reward;
    }

}

