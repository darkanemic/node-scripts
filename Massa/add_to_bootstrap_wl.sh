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

function AddToWL {
	read -r -p "Введите адрес ноды которую будем прикуривать:" NeedBootstrapIP
	echo $(${CLI} node_bootstrap_whitelist add $NeedBootstrapIP)
	line
	echo "IP $NeedBootstrapIP добавлен в whaitelist"
	line
}

clear
colors
cd $HOME/massa/massa-client/
source $HOME/.profile
CLI="$HOME/massa/massa-client/./massa-client --pwd ${massa_pass}"

AddToWL
