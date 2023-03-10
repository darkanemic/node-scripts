#!/bin/bash

for((turn=1; turn<11; turn++))
do
        printf "Turn: ""$turn\n"
        solana airdrop 1
        printf "sleep"
        for((sec=0; sec<5; sec++))
        do
                printf "."
                sleep 1
        done
        printf "\n"
done
