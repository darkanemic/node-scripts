#!/bin/bash
cd $HOME/charon-distributed-validator-node && docker-compose down
cp docker-compose.yml docker-compose.yml_bkp && git pull
docker-compose up -d
