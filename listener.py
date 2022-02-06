from web3 import Web3
from web3.middleware import geth_poa_middleware
from Blockchain.Contract import Contract
import asyncio
import logging
import sqlite3

logging.basicConfig(
    format='%(asctime)s %(levelname)-5s %(message)s',
    level=logging.INFO,
    datefmt='%Y-%m-%d %H:%M:%S')
log = logging.getLogger(__name__)


w3 = Web3(Web3.IPCProvider('/home/markma/NFT/eth/data/geth.ipc'))
w3.middleware_onion.inject(geth_poa_middleware, layer=0)
c = Contract(['./contracts/Artopus.sol'], import_remappings={
    "@openzeppelin": "/node_modules/@openzeppelin"})
artopus = w3.eth.contract(
    address="0xDA741963883751370739861C7c56BfD705075C3C",
    abi=c.abi
)
con = sqlite3.connect('/home/markma/NFT/database/nft.db', isolation_level=None)
cur = con.cursor()


def handle_event(event):
    _from = event["args"]["from"]
    _to = event["args"]["to"]
    tid = event["args"]["tokenId"]
    tx = event["transactionHash"].hex()
    tURI = artopus.functions.tokenURI(tid).call()

    log.info(f"{_from=}, {_to=}, {tid=}, {tx=}, {tURI=}")

    # insert to the database
    cur.execute("insert into TXs values (?, ?, ?, ?, ?)",
                (tx, _from, _to, tid, tURI))


async def log_loop(event_filter, poll_interval):
    while True:
        for event in event_filter.get_new_entries():
            handle_event(event)
        await asyncio.sleep(poll_interval)


def main():
    event_filter = artopus.events.Transfer.createFilter(fromBlock="latest")
    loop = asyncio.get_event_loop()
    try:
        loop.run_until_complete(
            asyncio.gather(
                log_loop(event_filter, 2),
            ))
    finally:
        loop.close()


if __name__ == '__main__':
    main()
