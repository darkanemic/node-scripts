#!/bin/bash


function OutputPause {
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


function show_whitelist {
	line
	cat $HOME/massa/massa-node/base_config/bootstrap_whitelist.json
	line
}


function add_to_whitelist {
	read -r -p "Введите адреса нод которые будем прикуривать (через пробел):" NeedBootstrapIP
	echo $(${CLI} node_bootstrap_whitelist add $NeedBootstrapIP)
	line
	echo "IP $NeedBootstrapIP добавлен(ы) в whitelist"
}


function show_status {
	line
	echo $(${CLI} get_status) | grep "Node's ID:"
	line
}


CLI="$HOME/massa/massa-client/./massa-client --pwd ${massa_pass}"

clear
colors
cd $HOME/massa/massa-client/
add_to_whitelist
show_whitelist
#show_status

