#!/bin/bash


function OutputPause(){
	sleep 2s
}


function colors {
    GREEN="\e[32m"
    RED="\033[31m"
    NORMAL="\e[0m"
    WARN="\033[41m\033[30m"
    GOOD="\033[30m\033[42m"
}


function line {
  echo -e "${GREEN}═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════${NORMAL}"
}


function get_wallet_address(){
	echo $(${CLI} wallet_info | grep Address | awk '{ print $2 }')
}


function get_balance(){
	echo $(${CLI} wallet_info | grep "Balance" | awk '{ print $2 }' | sed 's/final=//;s/,//')
}

function get_rolls(){
    echo $(${CLI} wallet_info | grep "Rolls" | awk '{ print $2 }' | sed 's/active=//;s/,//')
}


function buy_roll(){
	BuyRollResult=$(${CLI} buy_rolls $wallet_address 1 0)
	echo $BuyRollResult
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
    echo Last status update: ${date}
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
        echo -n -e " time until refresh \r${WTIMEOUT} ${CH_S[ITEM_ARR]}"
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

function get_int_balance {
    balance=$(get_balance)
    int_balance=${balance%%.*}
    echo $int_balance
}

clear
colors
cd $HOME/massa/massa-client/
source $HOME/.profile
CLI="$HOME/massa/massa-client/./massa-client --pwd ${massa_pass}"
wallet_address=$(get_wallet_address)

while true
do      
        cat "banner (2).txt"
        line
        int_balance=""
        echo -e "${GREEN} MASSA monitor ${NORMAL}"
        line
        int_balance=$(get_int_balance)
        if [[ ${#int_balance} > 0 ]]; then
                echo -e "${GOOD} Node work properly ${NORMAL}"
                line
                echo "Current wallet balance: $(get_int_balance) IRONs"
                echo "Current active rolls  : $(get_rolls) ROLLs"
                line
                if [ $int_balance -gt "99" ]; then
                    echo "Balance great than 100 IRON, then Buy a Roll..."
               	    line
                    buy_roll
		        else
                    echo -e "Balance less than 100, wait until the balance will be replenished... Request more in faucet... \n\t"
                    echo  "Address for request tokens : $wallet_address"
                    line
                fi
                show_last_update
                line
        else
            show_last_update
            line
            echo -e "${WARN} The node is not running correctly...The bootstrap may be missing... ${NORMAL}"
            line
        fi
        line
        logs=$(journalctl -n 10 -u massa)
        echo $logs
        line
        line
        wait_more "60"
        clear
done