#!/bin/bash
cd $HOME/charon-distributed-validator-node && docker-compose down
mv docker-compose.yml docker-compose.yml_bkp && git pull
docker-compose up -d
