// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Artopus is ERC721URIStorage, AccessControl{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BUYER_ROLE = keccak256("BUYER_ROLE");

    constructor() ERC721("Artopus", "APS") {
        // _setupRole(MINTER_ROLE, minter);
        // _setupRole(BURNER_ROLE, burner);
         _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    uint256 public constant price = 2 ether;

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function create(address player, string memory tokenURI)
        external
        onlyRole(MINTER_ROLE)    
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }


    function buy(address sender, string memory tokenURI)
        external
	    payable
        onlyRole(BUYER_ROLE)
        returns (uint256)
    {
        require(msg.value >= price);             
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        return newItemId;
    }

    function withdraw() 
        onlyRole(DEFAULT_ADMIN_ROLE) 
        external 
    {
        payable(msg.sender).transfer(address(this).balance);
    }

    fallback() external payable {}    
    receive() external payable {}

}
