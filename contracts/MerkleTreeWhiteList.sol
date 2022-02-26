// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


abstract contract MerkleTreeWhiteList is Context, Ownable{

    bytes32 public roothash;
    
    constructor(bytes32 roothash_){
	roothash = roothash_;
    }

    modifier whitelisted(bytes32[] calldata proof)
    {
	bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
	require(MerkleProof.verify(proof, roothash, leaf), "no access");
	_;
    }

    function setRootHash(bytes32 roothash_) public onlyOwner{
	roothash = roothash_;
    }
    
}
