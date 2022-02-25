from eth_account.messages import encode_structured_data
from web3 import Web3
import sys


w3 = Web3()

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


msg["message"]["whitelisted"] = sys.argv[3]
msg["domain"]["verifyingContract"] = sys.argv[2]
message = encode_structured_data(msg)
sk = sys.argv[1]  # signing private okey
s = w3.eth.account.sign_message(message, sk)
print(s.signature.hex())
