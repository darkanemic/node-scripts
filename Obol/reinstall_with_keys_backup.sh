#!/bash/bin

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

function backup_keys {
    echo -e "${GOOD} Backup Obol keys localy to folder $HOME/backup_obol ${NORMAL}"
    mkdir -p $HOME/backup_obol
    cp -r $HOME/charon-distributed-validator-node/.charon/ $HOME/backup_obol
}

function remove_obol {
    echo -e "${GOOD} Swich off Obol conteiners. Delete Obol folder... ${NORMAL}"
    docker-compose -f $HOME/charon-distributed-validator-node/docker-compose.yml down
    rm -rf $HOME/charon-distributed-validator-node
}

function clear_volumes {
    echo -e "${GOOD} Clearing containers/images/volumes... $HOME/backup_obol ${NORMAL}"
    echo "y" | docker container prune &> /dev/null && echo "y" | docker image prune -a &> /dev/null && echo "y" | docker volume prune -f &> /dev/null
}

function install_obol {
    echo -e "${GOOD} Install obol... ${NORMAL}"
    line
    git clone https://github.com/ObolNetwork/charon-distributed-validator-node.git
    cd $HOME/charon-distributed-validator-node/
    git checkout -- $HOME/charon-distributed-validator-node/docker-compose.yml
    cp $HOME/charon-distributed-validator-node/.env.sample $HOME/charon-distributed-validator-node/.env
    echo -e "\nGETH_PORT_HTTP=18545" >> $HOME/charon-distributed-validator-node/.env
    echo -e "\nLIGHTHOUSE_PORT_P2P=19000" >> $HOME/charon-distributed-validator-node/.env
    echo -e "\nMONITORING_PORT_GRAFANA=4000" >> $HOME/charon-distributed-validator-node/.env
    echo -e "\nCHARON_P2P_EXTERNAL_HOSTNAME=$(curl -s ifconfig.me)" >> $HOME/charon-distributed-validator-node/.env
    sed -i -e 's/9100:9100/19100:9100/' $HOME/charon-distributed-validator-node/docker-compose.yml
}

function restore_keys {
    echo -e "${GOOD} Restoring keys ${NORMAL}"
    mkdir -p $HOME/charon-distributed-validator-node/.charon/
    cp -r $HOME/backup_obol/.charon $HOME/charon-distributed-validator-node/
    chmod o+rw -R $HOME/charon-distributed-validator-node
    sudo chown -R 1000:1000 $HOME/charon-distributed-validator-node/.charon/
}

function obol_up {
    echo -e "${GOOD} Obol UP ${NORMAL}"
    docker-compose -f $HOME/charon-distributed-validator-node/docker-compose.yml up -d
}

clear
colors
line
echo -e "${GOOD} Obol reinstall. dArk#0149 ${NORMAL}"
line
wait_more "5"
backup_keys
line
wait_more "5"
remove_obol
line
clear_volumes
line
install_obol
line
restore_keys
line
obol_up
line
echo -e "${GOOD} Installation is complete ${NORMAL}"
line