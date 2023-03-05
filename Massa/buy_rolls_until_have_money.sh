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
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}


function get_wallet_address(){
	echo $(${CLI} wallet_info | grep Address | awk '{ print $2 }')
}


function get_balance(){
	echo $(${CLI} wallet_info | grep "Balance" | awk '{ print $2 }' | sed 's/final=//;s/,//')
}


function buy_roll(){
	#BuyRollResult=$(${CLI} buy_rolls $wallet_address 1 0)
	#echo $BuyRollResult
	OutputPause
    line
}


function get_wallet_info {
    echo $(${CLI} wallet_info)
}


function wait(sec) {
    printf "sleep"
        for((m=0; m<$sec; m++))
        do
                printf "."
                sleep 1s
        done
        printf "\n"
}


function show_lust_update  {
        date=$(date +"%H:%M")
        echo Last Update: ${date}
}

clear
colors
cd $HOME/massa/massa-client/
source $HOME/.profile
CLI="$HOME/massa/massa-client/./massa-client --pwd ${massa_pass}"
wallet_address=$(get_wallet_address)

while true
do
        balance=$(get_balance)
        int_balance=${balance%%.*}
        echo "We have ${int_balance} tokens on balance"
        line
        if [ $int_balance -gt "100" ]; then
                echo "Balance great than 100, then Buy a Roll..."
               	line
                buy_roll
		else
                echo "Balance less than 100, wait until the balance will be replenished... Request more in faucet..."
        fi
        show_lust_update
        wait(60)
done