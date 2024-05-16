#!/usr/bin/env bash

cd /home/aya
mkdir -p aya-node/target/release
cd aya-node
wget https://github.com/worldmobilegroup/aya-node/releases/download/devnet-v.0.2.0/wm-devnet-chainspec.json
wget -P target/release https://github.com/worldmobilegroup/aya-node/releases/download/devnet-v.0.2.0/aya-node
chmod +x target/release/aya-node

