#!/usr/bin/env bash

datadir="/home/markma/NFT/eth/data"
config_dir="/home/markma/NFT/config"

read -t 3 -n 1 -p "Delete data folder?(y/[n])? " answer
echo ""
answer=${answer:-n}
[[ "$answer" = 'y' ]] && command rm -r $datadir

sk1="a3bf9e710e894e4e4cb3535fe11404e2a382ebaa993610e09abea3162009e98b"
sk2="5b8c4f1eeb02a74fa98bfda97a2136cf8e171fd4190661f66ade9895381f3cba"
addr1="8c936f0ed2bd18a1891a21ff183f7564ec18801f"
addr2="3d460b4da4c97434344dc5966621ff970f948506"


geth account import --datadir $datadir --password <(echo "") <(echo $sk1)
geth account import --datadir $datadir --password <(echo "") <(echo $sk2)

geth init --datadir $datadir $config_dir/genesis.json

geth --http --http.corsdomain="*" --http.api "admin,eth,debug,miner,net,txpool,personal,web3"  --datadir $datadir --dev --http.addr 0.0.0.0 --http.vhosts="*" --allow-insecure-unlock --unlock "$addr1, $addr2" --password <(echo "")
