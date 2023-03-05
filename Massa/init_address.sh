#!/bin/bash

function OutputPause(){
	sleep 2s
}

function BackupKeys(){
	echo "Делаем бэкап ключей в папку $HOME/backup_massa/"
	mkdir -p $HOME/backup_massa
	cp $HOME/massa/massa-node/config/node_privkey.key $HOME/backup_massa/node_privkey.key
	cp $HOME/massa/massa-client/wallet.dat $HOME/backup_massa/wallet.dat
	OutputPause
}

function GetWalletAddress(){
	echo $(${CLI} wallet_info | grep Address | awk '{ print $2 }')
}

function GetBalance(){
	echo $(${CLI} wallet_info | grep "Balance" | awk '{ print $2 }' | sed 's/final=//;s/,//')
}

function CheckKeys(){
	if [ -f $HOME/massa/massa-node/config/node_privkey.key ]; then
		echo true
	else
		echo false
	fi
}

function GenerateKeys(){
	if [ ! CheckKeys ]; then
		echo "Ключи не обнаружены генерируем новые ключи..."
		$({CLI} wallet_generate_secret_key)
		OutputPause
	else
		echo "Обнаружены старые ключи, будем использовать их..."
		OutputPause
	fi
}

function BuyRoll(){
	echo "Покупаем Roll..."
#	BuyRollResult=$(${CLI} buy_rolls $wallet_address 1 0)
#	echo $BuyRollResult
	OutputPause
}

function StakingAddressReg(){
	echo "Регистрируем стейкинг адресс..."
	echo $(${CLI} node_start_staking $wallet_address)
	OutputPause
	staking_address=$(${CLI} node_get_staking_addresses)
	echo "Ваш адресс стейкинга теперь: $staking_address"
	OutputPause
}

clear
source $HOME/.profile
CLI="$HOME/massa/massa-client/./massa-client --pwd ${massa_pass}"

wallet_address=$(GetWalletAddress)
GenerateKeys
BackupKeys

echo "Ваш адресс для запроса токенов: $wallet_address"
OutputPause

balance=$(GetBalance)
integer_balance=${balance%%.*}

if [ $integer_balance -gt "100" ]; then
	echo "На балансе есть $integer_balance токенов..."
	BuyRoll
	OutputPause
else
	echo "На балансе менее 100 монет. Запросите дополнительные монеты в дискорде Massa в ветке #testnet-faucet"
	echo "Я уже запросили токены, подождал пару минут и мы можем продолжать (Y). Прервать скрипт (Нажатие любой другой клавиши)"
	read -n 1 input
	if [[ "$input" == "Y" || "$input" == "y" ]]; then
		echo "Продолжаем выполнение..."
		OutputPause
		echo "На балансе есть $integer_balance токенов..."
		OutputPause
		BuyRoll
	else
		echo "Прерываем выполнение скрипта..."
		exit
	fi
fi
StackingAddressReg
read -p "Введите ваш discordID (Узнать можно в боте Massa):" massa_discord_id
node_testnet_rewards_program_ownership_proof $wallet_address $massa_discord_id
echo "Для завершения регистрации, отправте данный код боту..."
