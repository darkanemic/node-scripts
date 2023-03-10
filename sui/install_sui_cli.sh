#!/bin/bash
sudo apt-get update
sudo apt-get install -y --no-install-recommends
apt install tzdata
apt install ca-certificates
apt install build-essential -y
apt install libssl-dev
apt install libclang-dev -y
apt install pkg-config
apt install openssl
apt install protobuf-compiler -y
apt install cmake -y
sudo apt install curl -y
sudo apt-get install git-all -y
sudo apt-get install screen
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh