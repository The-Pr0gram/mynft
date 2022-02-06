// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ico is Pausable, AccessControl{
    address public addr;
    uint256 public max_amount=100;
    uint256 public counter=0;
    mapping (address => uint) number_nft_user_owns;
    mapping (string => bool) tokenURIs;
    uint constant public MAX_NUMBER_NFT_USER_OWNS=5;
    bytes32 public constant WHITELISTED_ROLE = keccak256("WHITELISTED_ROLE");

    constructor(address _addr, address[] memory addresses, string[] memory _tokenURIs) {
        addr = _addr;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        for (uint i = 0; i < addresses.length; i++) {
            grantRole(WHITELISTED_ROLE, addresses[i]);
            number_nft_user_owns[addresses[i]] = 0;
        }
        for (uint i = 0; i < _tokenURIs.length; i++) {
            tokenURIs[_tokenURIs[i]] = true;
        }        
    }
    
    // "0xDA741963883751370739861C7c56BfD705075C3C", ["0x3D460b4Da4c97434344Dc5966621Ff970F948506"], ["a","b","c"]
    

    function buy(string memory tokenURI) 
    whenNotPaused
    onlyRole(WHITELISTED_ROLE)
    external 
    payable
    {
        // require(counter < max_amount, "max amount reached");
        // counter += 1;
        require(tokenURIs[tokenURI], "token is not available");   
        require(number_nft_user_owns[msg.sender] <= MAX_NUMBER_NFT_USER_OWNS, "max amount reached");     
        number_nft_user_owns[msg.sender] += 1;
        tokenURIs[tokenURI] = false;
        bytes memory payload = abi.encodeWithSignature("buy(address,string)", msg.sender, tokenURI);
        (bool success,) = addr.call{value: msg.value}(payload);
        require(success);
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE)  { _pause(); }
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE)  { _unpause(); }

    fallback() external payable {}  
    receive() external payable {}
}