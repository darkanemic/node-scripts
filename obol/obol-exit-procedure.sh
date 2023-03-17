#!/bin/bash

function colors {
    GREEN="\e[32m"
    RED="\033[31m"
    NORMAL="\e[0m"
    WARN="\033[41m\033[30m"
    GOOD="\033[30m\033[42m"
}


function line {
    echo -e "${GREEN}-------------------------------------------------------------------------------------------------------------${NORMAL}"
}


function script_name {
    line
    echo -e "${GOOD} Obol automatic exit procedure. ${NORMAL}"
    line
    wait_more "5"
}


function wait_more() {
    WTIMEOUT=$1
    ITEM_ARR=0 #current item counter
    CH_S[0]='-' #pseudographic items
    CH_S[1]='/'
    CH_S[2]='|'
    CH_S[3]='\'

    while [ $WTIMEOUT -ge 0 ]; do
    
        #print timeout and current pseudographic char
        echo -n -e "\r${WTIMEOUT} ${CH_S[ITEM_ARR]}"
        #tput rc #restore cursor position
        sleep 1
        
        #decrease timeout and increase current item ctr.
        let "WTIMEOUT=WTIMEOUT-1"
        let "ITEM_ARR=ITEM_ARR+1"
        
        if [ $ITEM_ARR -eq 4 ];then 
            #if items ctr > number of array items
            #starting with 0 item
            let "ITEM_ARR=0"
        fi
        
    done
    printf "\n"
} 


function obol_down {
    echo -e "${GOOD} Swich off Obol conteiners. ${NORMAL}"
    docker-compose -f $HOME/charon-distributed-validator-node/docker-compose.yml down
    line
}


function obol_update {
    echo -e "${GOOD} Update Obol. ${NORMAL}"
    cp $HOME/charon-distributed-validator-node/docker-compose.yml $HOME/charon-distributed-validator-node/docker-compose.yml_bkp
    cd $HOME/charon-distributed-validator-node/
    git pull
    line
}

function obol_up {
    echo -e "${GOOD} Obol up again. ${NORMAL}"
    docker-compose -f $HOME/charon-distributed-validator-node/docker-compose.yml up -d
    line
}

function set_exit_keys {
    echo -e "${GOOD} Set exit keys. ${NORMAL}"
    mkdir $HOME/charon-distributed-validator-node/.charon/exit_keys
    cp $HOME/charon-distributed-validator-node/.charon/validator_keys/keystore-0.* $HOME/charon-distributed-validator-node/.charon/exit_keys
    line
}

function start_exit_procedure {
    echo -e "${GOOD} Start exit procedure. ${NORMAL}"
    docker-compose -f $HOME/charon-distributed-validator-node/compose-voluntary-exit.yml up
    line
}

clear
colors
script_name
obol_down
obol_update
obol_up
set_exit_keys
wait_more "60"
start_exit_procedure


