#!/bin/bash

function colors {
    GREEN="\033[0;32m"
    RED="\033[31m"
    YELLOW="\033[0;33m"
    NORMAL="\033[0m"
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

function print_at_center(){
	# Get the text and the color
	local text=$1
	local color=$2

	# Get the width of the terminal
	local width=$(tput cols)

	# Calculate the number of spaces to add before and after the text
	local padding=$((($width - ${#text}) / 2))

	# Print the padding and the colored text
	printf "%${padding}s" && printf "\033[${color}%s\033[0m" "$text" && printf "%${padding}s\n"
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

function wait_more() {
    WTIMEOUT=$1
    ITEM_ARR=0 #current item counter
    CH_S[0]='-' #pseudographic items
    CH_S[1]='/'
    CH_S[2]='|'
    CH_S[3]='\'

    while [ $WTIMEOUT -ge 0 ]; do

        #print timeout and current pseudographic char
        echo -n -e "  time until refresh  \r  ${WTIMEOUT} ${CH_S[ITEM_ARR]}"
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


function progress_timer {
  local duration=$1
  local interval=1
  local elapsed=0
  local cols=$(tput cols)
  local color=$2
  local max_text_width=$((cols - 53))  # максимальная ширина текста с учетом прогресс-бара

  # set terminal to allow backspacing
  tput civis
#  stty -echo

  while [ $elapsed -le $duration ]; do
    local remaining=$((duration-elapsed))
    local minutes=$((remaining/60))
    local seconds=$((remaining%60))
    local progress=$((100-elapsed*100/duration))

    # calculate position to center text
    local text_width=$(( 15 + ${#minutes} + ${#seconds} + 6))  # ширина текста с учетом времени и разделителей
    local pos=$(( (max_text_width - text_width) / 2 ))

    printf "\r%${pos}s${color}Time until update: %02d:%02d${reset}" "" "${minutes}" "${seconds}"
    printf "${color} ["

    local i
    for ((i=0; i<progress/2; i++)); do
      printf "#"
    done

    for ((i=progress/2; i<50; i++)); do
      printf "-"
    done

    printf "]${NORMAL}"
    sleep $interval
    elapsed=$((elapsed+interval))
  done

  printf "\n"

  # reset terminal
#  stty echo
  tput cnorm
}


function obol_down {
    echo -e "${GOOD} Swich off Obol conteiners. ${NORMAL}"
    line
    docker-compose -f $HOME/charon-distributed-validator-node/docker-compose.yml down
    line
}


function obol_update {
    echo -e "${GOOD} Update Obol. ${NORMAL}"
    line
    cp $HOME/charon-distributed-validator-node/docker-compose.yml $HOME/charon-distributed-validator-node/docker-compose.yml_bkp
    git pull
    line
}

function obol_up {
    echo -e "${GOOD} Obol up again. ${NORMAL}"
    line
    docker-compose -f $HOME/charon-distributed-validator-node/docker-compose.yml up -d
    line
}

function set_exit_keys {
    echo -e "${GOOD} Set exit keys. ${NORMAL}"
    line
    if [ -d $HOME/charon-distributed-validator-node/.charon/exit_keys ]; then
        echo " Kyes already settled. Files alredy exist in folder..."
    else
        echo "No keys found. Lets create them..."
        mkdir $HOME/charon-distributed-validator-node/.charon/exit_keys
        cp $HOME/charon-distributed-validator-node/.charon/validator_keys/keystore-0.* $HOME/charon-distributed-validator-node/.charon/exit_keys
    fi
    wait_more "3"
    line
}

function correct_config {
    echo -e "${GOOD} Correcting voluantary-exit.cfg. ${NORMAL}"
    line
    sed -i 's/image: consensys\/teku:22.8.0/image: consensys\/teku:22.9.1/g' $HOME/charon-distributed-validator-node/compose-voluntary-exit.yml
    line
}

function start_exit_procedure {
    echo -e "${GOOD} Start exit procedure. ${NORMAL}"
    line
    docker-compose -f $HOME/charon-distributed-validator-node/compose-voluntary-exit.yml up
    line
}

function WaitPressY {
    read -n1 -s input
	if [[ "$input" == "Y" || "$input" == "y" ]]; then
		echo -e "${GOOD} Continue... ${NORMAL}"
	else
		echo -e "${GOOD} Exit from script... ${NORMAL}"
		exit
	fi
}

clear
cd $HOME/charon-distributed-validator-node/
colors
script_name
obol_down
obol_update
obol_up
set_exit_keys
correct_config
echo -e "${GOOD} We are waiting for synchronization for 10 minutes ${NORMAL}"
progress_timer "600" "$YELLOW"
#echo -e "${GOOD} Wait until the node is SYNCHRONIZED and only then press Y. ${NORMAL}"
#WaitPressY
start_exit_procedure


