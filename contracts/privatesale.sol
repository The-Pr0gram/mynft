// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./SignatureWhiteList.sol";

abstract contract Artopus{
    function buy(address owner) external payable virtual returns (uint256);
}

contract MysteryBox is Pausable, Ownable, SignatureWhiteList{

    Artopus public immutable artopus;
    
    constructor(Artopus artopus_, address signingPK)
	SignatureWhiteList("Artopus", "1", signingPK) {
	    artopus = Artopus(artopus_);
	    _pause();   
    }
        
    function buy(bytes calldata signature)
	external
	whenNotPaused
	whitelisted(signature)
	payable
	returns(uint256)
    {
    	uint256 tokenID = artopus.buy{value:msg.value}(_msgSender());
	    return tokenID;
    }
    
    function pause() external onlyOwner()  { _pause(); }
    function unpause() external onlyOwner() { _unpause(); }

    // fallback() external payable {}  
    // receive() external payable {}
}
