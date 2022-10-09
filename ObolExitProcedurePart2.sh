#!/bin/bash
cd $HOME/charon-distributed-validator-node/.charon
mkdir exit_keys && cp validator_keys/keystore-0.* exit_keys
docker-compose -f $HOME/charon-distributed-validator-node/compose-voluntary-exit.yml up
