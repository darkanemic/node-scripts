#!/bin/bash

function colors {
    GREEN="\e[32m"
    RED="\033[31m"
    NORMAL="\e[0m"
    WARN="\033[41m\033[30m"
    GOOD="\033[30m\033[42m"
}


function line {
    print_at_center "-------------------------------------------------------------------------------------------------------------" "$GREEN"
}


function script_name {
    line
    print_at_center " Obol automatic exit procedure. " "$GOOD"
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
    print_at_center  " Swich off Obol conteiners. " "$GOOD"
    docker-compose -f $HOME/charon-distributed-validator-node/docker-compose.yml down
    line
}


function obol_update {
    print_at_center  " Update Obol. " "$GOOD"
    cp $HOME/charon-distributed-validator-node/docker-compose.yml $HOME/charon-distributed-validator-node/docker-compose.yml_bkp
    git pull
    line
}

function obol_up {
    print_at_center  " Obol up again. " "$GOOD"
    docker-compose -f $HOME/charon-distributed-validator-node/docker-compose.yml up -d
    line
}

function set_exit_keys {
    print_at_center  " Set exit keys. " "$GOOD"
    if [ -d $HOME/charon-distributed-validator-node/.charon/exit_keys ]; then
        print_at_center  " Kyes already settled. Files alredy exist in folder..." "GOOD"
    else
        print_at_center  "No keys found. Lets create them..." "$GOOD"
        mkdir $HOME/charon-distributed-validator-node/.charon/exit_keys
        cp $HOME/charon-distributed-validator-node/.charon/validator_keys/keystore-0.* $HOME/charon-distributed-validator-node/.charon/exit_keys
    fi
    progress_timer 3 "$YELLOW"
    line
}

function correct_config {
    print_at_center  " Correcting voluantary-exit.cfg. " "$GOOD"
    sed -i 's/image: consensys\/teku:22.8.0/image: consensys\/teku:22.9.1/g' $HOME/charon-distributed-validator-node/compose-voluntary-exit.yml
    line
}

function start_exit_procedure {
    print_at_center " Start exit procedure. " "$GOOD"
    docker-compose -f $HOME/charon-distributed-validator-node/compose-voluntary-exit.yml up
    line
}

function WaitPressY {
    read -n1 -s input
	if [[ "$input" == "Y" || "$input" == "y" ]]; then
		print_at_center " Continue... " "$GOOD"
	else
		print_at_center " Exit from script... " "$GOOD"
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
print_at_center " We are waiting for synchronization for 10 minutes " "$GOOD"
progress_timer 600 "$YELLOW"
#echo -e "${GOOD} Wait until the node is SYNCHRONIZED and only then press Y. ${NORMAL}"
#WaitPressY
start_exit_procedure


