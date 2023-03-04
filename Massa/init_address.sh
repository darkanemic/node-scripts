#!/bin/bash
function BackupKeys(){
    echo "Бэкапим ключи в папку $HOME/backup_massa/"
    mkdir $HOME/backup_massa > /dev/null
    cp $HOME/massa/massa-node/config/node_privkey.key $HOME/backup_massa/node_privkey.key
    cp $HOME/massa/massa-client/wallet.dat $HOME/backup_massa/wallet.dat
    sleep 3s
    {BackupKeys}=true
}

function GetWalletAdress(){
    CLI=./massa-client --pwd $massa_pass
    {GetWalletAdress}=echo $(${CLI} wallet_info | grep Address | awk '{ print $2 }')
}

CLI=./massa-client --pwd $massa_pass
massa_wallet_address=$(GetWalletAdress)

cd $HOME/massa/massa-client
echo source $HOME/.profile
#$({CLI} wallet_generate_secret_key)
clear
BackupKeys
echo "Ваш адресс для запроса токенов:" $massa_wallet_address
sleep 3s
echo "На вашем кошельке уже должны быть токены запрошеные в дискорде"
sleep 3s
balance=$(${CLI} wallet_info | grep "Balance" | awk '{ print $2 }' | sed 's/final=//;s/,//')
int_balance=${balance%%.*}
echo "balance" $int_balance
if [ $int_balance -gt "100" ]; then
    echo "На балансе есть " $int_balance "токенов. Приступаем к покупке первого ролла..."
    sleep 2s
    resp=$(./massa-client --pwd $massa_pass buy_rolls $massa_wallet_address 1 0)
    echo $resp
    wallet_info=$(./massa-client --pwd $massa_pass wallet_info)
    echo $wallet_info
    sleep 2s
elif [ $int_balance -gl "100" ]; then
    echo "На балансе менее 100 монет. Запросите дополнительные монеты в дискорде Massa"
    sleep 2s
fi
echo "Регистрируем стейкинг адресс:"
sleep 2s
echo node_start_staking $massa_wallet_address
sleep 2s
massa_staking_address=$(./massa-client --pwd $massa_pass node_get_staking_addresses)
echo "Ваш адресс стейкинга теперь:" $massa_staking_address
sleep 2s
echo "Введите ваш discordID(Узнать можно в боте Massa):"
read massa_discord_id
node_testnet_rewards_program_ownership_proof $massa_wallet_address $massa_discord_id
echo "Для завершения регистрации, отправте данный код боту..."
date=$(date +"%H:%M")
echo Update : ${date}