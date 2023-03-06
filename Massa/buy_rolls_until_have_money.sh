#!/bin/bash


function OutputPause(){
	sleep 2s
}


function colors {
    GREEN="\e[32m"
    RED="\e[39m"
    NORMAL="\e[0m"
}


function line {
  echo -e "${GREEN}-------------------------------------------------------------------------------------------------------------${NORMAL}"
}


function get_wallet_address(){
	echo $(${CLI} wallet_info | grep Address | awk '{ print $2 }')
}


function get_balance(){
	echo $(${CLI} wallet_info | grep "Balance" | awk '{ print $2 }' | sed 's/final=//;s/,//')
}


function buy_roll(){
	BuyRollResult=$(${CLI} buy_rolls $wallet_address 1 0)
	echo $BuyRollResult
	OutputPause
    line
}


function get_wallet_info {
    echo $(${CLI} wallet_info)
}


function wait() {
    printf "sleep"
    sec=$1
    for((m=0; m<$sec; m++))
    do
        printf "."
        sleep 1s
    done
    printf "\n"
}


function show_last_update  {
    date=$(date +"%e %b %H:%M")
    echo Last Update: ${date}
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


clear
colors
cd $HOME/massa/massa-client/
source $HOME/.profile
CLI="$HOME/massa/massa-client/./massa-client --pwd ${massa_pass}"
wallet_address=$(get_wallet_address)
line
echo -e "${GREEN}from dArk#0149 with cyberlove${NORMAL}"
line

while true
do
        balance=$(get_balance)
        int_balance=${balance%%.*}
        line
        echo "We have ${int_balance} tokens on balance"
        line
        if [ $int_balance -gt "100" ]; then
                echo "Balance great than 101, then Buy a Roll..."
               	line
                buy_roll
		else
                echo "Balance less than 101, wait until the balance will be replenished... Request more in faucet..."
                echo "Address for request: $wallet_address"
                line
        fi
        show_last_update
        line
        grep balance $(get_wallet_info)
        grep rolls $(get_wallet_info)
        line
        wait_more "60"
done