#!/usr/bin/env python3

from eth_account.messages import encode_structured_data
from web3 import Web3
import sys
import argparse

msg = {
    "types": {
        "EIP712Domain": [
            {
                "name": "name",
                "type": "string"
            },
            {
                "name": "version",
                "type": "string"
            },
            {
                "name": "chainId",
                "type": "uint256"
            },
            {
                "name": "verifyingContract",
                "type": "address"
            }
        ],
        "WhiteListAddress": [
            {
                "name": "whitelisted",
                "type": "address"
            }
        ]
    },
    "primaryType": "WhiteListAddress",
    "domain": {
        "name": "Artopus",
        "version": "1",
        "chainId": 1,  # main net chainid;
        "verifyingContract": None  # our contract address
    },
    "message": {
        "whitelisted": None  # user's address
    }
}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Sign Message')
    parser.add_argument("sk", metavar="private_key", type=str)
    parser.add_argument("contract", metavar="verifyingContract", type=str)
    parser.add_argument("address", metavar="whitelist_address", type=str)
    parser.add_argument("cid", metavar="chain id", type=int, default=1,
                        nargs='?', help="default: %(default)s")

    args = parser.parse_args()
    sk = args.sk  # signing private okey
    msg["message"]["whitelisted"] = args.address
    msg["domain"]["chainId"] = args.cid
    msg["domain"]["verifyingContract"] = args.contract
    message = encode_structured_data(msg)
    s = Web3().eth.account.sign_message(message, sk)
    print(s.signature.hex())


def sign(sk, contract, whitelisted, cid):
    msg["message"]["whitelisted"] = whitelisted
    msg["domain"]["chainId"] = cid
    msg["domain"]["verifyingContract"] = contract
    message = encode_structured_data(msg)
    s = Web3().eth.account.sign_message(message, sk)
    return s.signature
