#!/bin/bash


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


function allow_all_to_bootstrap {
	echo $(${CLI} node_bootsrap_whitelist allow-all)
	line
	echo "Теперь можно прикуривать любые ноды"
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
allow_all_to_bootstrap
show_whitelist
#show_status