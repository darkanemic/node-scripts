#!/bin/bash


function colors {
    GREEN="\033[0;32m"
    RED="\033[31m"
    YELLOW="\033[0;33m"
    NORMAL="\033[0m"
    WARN="\033[41m\033[30m"
    GOOD="\033[30m\033[42m"
}


function display_txt_file_center(){
	columns="$(tput cols)"
	color=$2
	while IFS= read -r line; do
	      printf "\e${color}%*s\e[0m\n" $((($(tput cols) + ${#line})/2)) "$line"
	done < "$1"
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




function line {
	print_at_center "═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════" "$GREEN"
}


function get_wallet_address(){
	echo $(${CLI} wallet_info | grep Address | awk '{ print $2 }')
}


function get_balance(){
	echo $(${CLI} wallet_info | grep "Balance" | awk '{ print $2 }' | sed 's/final=//;s/,//')
}


function get_int_balance {
    balance=$(get_balance)
    int_balance=${balance%%.*}
    echo $int_balance
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


function show_last_update  {
    date=$(date +"%e %b %H:%M")
    print_at_center " Last status update: ${date} " "$GREEN"
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
  stty -echo

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
  stty echo
  tput cnorm
}


clear
colors
source $HOME/.profile
cd $HOME/massa/massa-client/
curl -s https://raw.githubusercontent.com/darkanemic/node-scripts/main/massa/banner.txt > $HOME/massa/massa-client/banner.txt
CLI="$HOME/massa/massa-client/./massa-client --pwd ${massa_pass}"
wallet_address=$(get_wallet_address)

while true
do
        display_txt_file_center "banner.txt" "$RED"
        line
        int_balance=""
        print_at_center "  monitor and roll auto buy " "$YELLOW"
        line
        int_balance=$(get_int_balance)
        if [[ ${#int_balance} > 0 ]]; then
                print_at_center " Node work properly " "$GOOD"
                line
                print_at_center "Current wallet balance: $(get_int_balance) IRONs" "$YELLOW"
                print_at_center "Current active rolls  : $(get_rolls) ROLLs" "$YELLOW"
                line
                if [ $int_balance -gt "99" ]; then
                    print_at_center "Balance great than 100 IRON, then Buy a Roll..." "$YELLOW"
               	    line
                    buy_roll
		        else
                    print_at_center  "Balance less than 100, wait until the balance will be replenished... Request more in faucet..." "$YELLOW"
                    print_at_center  "Address for request tokens : $wallet_address" "$YELLOW"
                    line
                fi
                show_last_update
                line
        else
            show_last_update
            line
            print_at_center "$ The node is not running correctly...The bootstrap may be missing..." "$WARN"
            line
        fi
        line
        logs=$(journalctl -n 10 -u massa)
#        echo $logs
        line
	progress_timer 30 "$YELLOW"
#        wait_more "60"
        clear
done
