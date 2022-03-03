// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Artopus is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Pausable, Ownable, PaymentSplitter{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint256 public constant PRICE = 100000;
    address public minter;
    uint256 public constant MAX_ARTOPUS = 5000;
    uint256 public constant MAX_ARTOPUS_PRE_ADDRESS = 5;
    string public constant URI_PROVENACE = "ipfs://xyz";

    constructor(address[] memory payees, uint256[] memory shares_, address minter_) 
        ERC721("Artopus", "APS") PaymentSplitter(payees, shares_) {
            minter = minter_;
        }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }


    function setMinter(address minter_) external onlyOwner()
    {
	    minter = minter_;
    }

    
    function buy(address owner)
	    external    
	    payable
	    returns (uint256)
    {
	    require(totalSupply() < MAX_ARTOPUS, "purchase would exceed max supply");
	    require(balanceOf(_msgSender()) < MAX_ARTOPUS_PRE_ADDRESS, "max number of mint pre address reached");
	    require(_msgSender() == minter, "minter is not authorized");
        require(msg.value >= PRICE, "insufficient eth");             
        uint256 newItemId = _tokenIds.current();
	    _tokenIds.increment();  
        _safeMint(owner, newItemId);
        return newItemId;
    }
    
    
    
    // pasue first than call this function
    // otherwise, one may burn a token before we can set URIs.
    function batchSetTokenURIs(string[] memory URIs)
	    external
	    onlyOwner()
    {
	    require(URIs.length == totalSupply(), "URIs length is incorrect");
	    for(uint256 i=0;i<URIs.length;i++){
	        uint256 tokenId = tokenByIndex(i);
            require(bytes(tokenURI(tokenId)).length == 0, "URI is not empty");
	        _setTokenURI(tokenId, URIs[i]);
	    }       
	
    }
    

    // The following functions are overrides required by Solidity.
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }


    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }


    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    
    // fallback() external payable {}    
}
