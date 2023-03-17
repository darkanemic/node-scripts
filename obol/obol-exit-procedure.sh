#!/bin/bash

function colors {
    GREEN="\033[0;32m"
    RED="\033[31m"
    YELLOW="\033[0;33m"
    NORMAL="\033[0m"
    WARN="\033[41m\033[30m"
    GOOD="\033[30m\033[42m"
    ORANGE_TITLE="\033[30;48;5;208m"
}

function print_at_center(){
	# Get the text and the color
	local text=$1
	local color=$2

	# Get the width of the terminal
	local width=110

	# Calculate the number of spaces to add before and after the text
	local padding=$((($width - ${#text}) / 2))

	# Print the padding and the colored text
	printf "%${padding}s" && printf "\033[${color}%s\033[0m" "$text" && printf "%${padding}s\n"
}

function line {
    echo -e "${GREEN}--------------------------------------------------------------------------------------------------------------${NORMAL}"
}


function script_name {
    line
    print_at_center " Obol automatic exit procedure. " "$ORANGE_TITLE"
    line
}


function progress_timer {
  local duration=$1
  local interval=1
  local elapsed=0
  local cols=$(tput cols)
  local color=$2
  if [ $3 == "LEFT" ]; then
    cols=110
  fi
  local max_text_width=$((cols - 53))  # максимальная ширина текста с учетом прогресс-бара
    
  # set terminal to allow backspacing
  tput civis
#  stty -echo

   # calculate position to center text
   local text_width=$(( 15 + ${#minutes} + ${#seconds} + 6))  # ширина текста с учетом времени и разделителей
   local pos=$(( (max_text_width - text_width) / 2 ))

  while [ $elapsed -le $duration ]; do
    local remaining=$((duration-elapsed))
    local minutes=$((remaining/60))
    local seconds=$((remaining%60))
    local progress=$((100-elapsed*100/duration))

    printf "\r%${pos}s${color} Time until next step: %02d:%02d${reset}" "" "${minutes}" "$(${seconds}"+" ")
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
    print_at_center " Swich off Obol conteiners. " "$GOOD"
    line
    docker-compose -f $HOME/charon-distributed-validator-node/docker-compose.yml down
    line
}


function obol_update {
    print_at_center " Update Obol. " "$GOOD"
    line
    cp $HOME/charon-distributed-validator-node/docker-compose.yml $HOME/charon-distributed-validator-node/docker-compose.yml_bkp
    git pull
    line
}

function obol_up {
    print_at_center " Obol up again. " "$GOOD"
    line
    docker-compose -f $HOME/charon-distributed-validator-node/docker-compose.yml up -d
    line
}

function set_exit_keys {
    print_at_center " Set exit keys. " "$GOOD"
    line
    if [ -d $HOME/charon-distributed-validator-node/.charon/exit_keys ]; then
        echo " Keуs already settled. Files alredy exist in folder..."
    else
        echo "No keys found. Lets create them..."
        mkdir $HOME/charon-distributed-validator-node/.charon/exit_keys
        cp $HOME/charon-distributed-validator-node/.charon/validator_keys/keystore-0.* $HOME/charon-distributed-validator-node/.charon/exit_keys
    fi
    line
}

function correct_config {
    print_at_center " Correcting voluantary-exit.cfg. "  "$GOOD"
    sed -i 's/image: consensys\/teku:22.8.0/image: consensys\/teku:22.9.1/g' $HOME/charon-distributed-validator-node/compose-voluntary-exit.yml
    line
}

function start_exit_procedure {
    print_at_center " Start exit procedure. " "$GOOD"
    line
    docker-compose -f $HOME/charon-distributed-validator-node/compose-voluntary-exit.yml up
    line
}

function WaitPressY {
    read -n1 -s input
	if [[ "$input" == "Y" || "$input" == "y" ]]; then
		print_at_center "$ Continue... " "$GOOD"
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
line
progress_timer "600" "$ORANGE_TITLE" "LEFT"
#print_at_center "${GOOD} Wait until the node is SYNCHRONIZED and only then press Y. ${NORMAL}"
#WaitPressY
start_exit_procedure