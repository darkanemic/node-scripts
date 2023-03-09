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
    echo "Backup Obol keys localy to folder $HOME/backup_obol"
    mkdir -p $HOME/backup_obol
    cp -r $HOME/charon-distributed-validator-node/.charon/ $HOME/backup_obol
}

function remove_obol {
    echo "Swich off Obol conteiners. Delete obol folder..."
    docker-compose -f $HOME/charon-distributed-validator-node/docker-compose.yml down
    rm -rf $HOME/charon-distributed-validator-node
}

function clear_volumes {
    echo "y" | docker container prune && echo "y" | docker image prune -a && echo "y" | docker volume prune -f
}

function install_obol {
    echo "Install obol..."
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

functino restore_keys {
    mkdir $HOME/charon-distributed-validator-node/.charon/
    cp -r $HOME/backup_obol/.charon $HOME/charon-distributed-validator-node/
    chmod o+rw -R $HOME/charon-distributed-validator-node
    sudo chown -R 1000:1000 $HOME/charon-distributed-validator-node/.charon/
}

functino obol_up {
    docker-compose -f $HOME/charon-distributed-validator-node/docker-compose.yml up -d
}

line
echo "Obol reinstall with local key backup. dArk#0149"
line
wait_more(3)
colors
line
backup_keys
wait_more(3)
line
remove_obol
wait_more(3)
line
clear_volumes
wait_more(3)
line
install_obol
line
wait_more(3)
obol_up
line
echo "{GOOD}Installation complite...{NORMAL}"
line