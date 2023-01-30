!#bin/bash
sudo apt-get update
sudo apt-get install -y --no-install-recommends
apt install tzdata
apt install ca-certificates
apt install build-essential (y)
apt install libssl-dev
apt install libclang-dev (y)
apt install pkg-config
apt install openssl
apt install protobuf-compiler (y)
apt install cmake (y)
sudo apt install curl (y)
sudo apt-get install git-all (y)
sudo apt-get install screen
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh  (жмем 1 и энтер)
source $HOME/.cargo/env
rustup install stable
rustup update stable
rustup default stable
screen -S suicli
cargo install --locked --git https://github.com/MystenLabs/sui.git --branch testnet sui
sui genesis --force
rm -rf .sui/sui_config/client.yaml
sui client