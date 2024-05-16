#!/usr/bin/env bash

/home/aya/aya-node/target/release/aya-node \
    --base-path /home/aya/aya-node/data/validator \
    --validator \
    --chain /home/aya/aya-node/wm-devnet-chainspec.json \
    --port 30333 \
    --rpc-port 9944 \
    --log info \
    --bootnodes /dns/devnet-rpc.worldmobilelabs.com/tcp/30340/ws/p2p/12D3KooWRWZpEJygTo38qwwutM1Yo7dQQn8xw1zAAWpfMiAqbmyK

