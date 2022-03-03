// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./SignatureWhiteList.sol";

/**
 * @title Artopus ERC721 token
 * @author Mark Ma
 */
contract Artopus is ERC721, ERC721URIStorage, ERC721Enumerable, ERC721Burnable, Pausable, Ownable, PaymentSplitter, SignatureWhiteList{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    // uint256 public PRICE;
    uint256 public constant MAX_ARTOPUS = 5000;    
    uint256 public constant MAX_ARTOPUS_PRE_ADDRESS = 5;
    uint256 public constant RESERVED_ARTOPUS = 50;
    string public constant contractURI = " ";
    string public constant URI_PROVENACE = "ipfs://xyz";
    string public baseURI;
    
    struct SaleConfig {
        bool allowBurn;
        bool allowPrivateSale;
        bool allowPublicSale;
        uint248 price; // do we want/allow to update price??
    }

    SaleConfig public saleConfig = SaleConfig(false, true, true, 1 gwei);

    constructor(string memory name, address[] memory payees, uint256[] memory shares_, address signingPK)
	// name and symbol?
        ERC721(name, name)
	PaymentSplitter(payees, shares_)
	SignatureWhiteList(name, "", signingPK)
    {
        for(;_tokenIds.current() < RESERVED_ARTOPUS; _tokenIds.increment())
        {
            _safeMint(_msgSender(), _tokenIds.current());
        }
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    
    function buy(address to) 
        private  
        returns (uint256)
    {
        require(_tokenIds.current() < MAX_ARTOPUS, "purchase would exceed max supply");
        // do want to limit the number of purchase or number of owned-token ? 
         require(balanceOf(_msgSender()) < MAX_ARTOPUS_PRE_ADDRESS, "max number of purchase pre address reached");  
        require(msg.value >= saleConfig.price, "insufficient eth");             
        uint256 newItemId = _tokenIds.current();
        _tokenIds.increment();  
        _safeMint(to, newItemId);
        return newItemId;
    }

    function publicBuy()
        external
        payable
        returns(uint256)
    {
        require(saleConfig.allowPublicSale, "public sale is not allowed");
        return buy(_msgSender());
    }

    function privateBuy(bytes calldata signature)
        external
        whitelisted(signature)
        payable
        returns(uint256)
    {
        require(saleConfig.allowPrivateSale, "private sale is not allowed");
	return buy(_msgSender());
    }

    function setSaleConfig(SaleConfig calldata saleConfig_)
        external
        onlyOwner()
    {
        saleConfig = saleConfig_;
    }
        

    // do we reveal all nft at the same time?
    function setBaseURI(string memory baseURI_)
	external
	onlyOwner()
    {
	require(bytes(baseURI).length == 0, "baseURI is already set");
	baseURI = baseURI_;
    }

    // The following functions are overrides required by Solidity.
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }


    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }


    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        require(saleConfig.allowBurn, "burning is not allowed");
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
