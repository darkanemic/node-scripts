#!/bin/bash
cd $HOME/charon-distributed-validator-node/.charon
cp validator_keys/keystore-0.* exit_keys
cd $HOME/charon-distributed-validator-node
docker-compose -f compose-voluntary-exit.yml up
