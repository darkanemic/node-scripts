 #!/bin/bash
 2
 3
 4 function OutputPause {
 5         sleep 2s
 6 }
 7
 8
 9 function colors {
10   GREEN="\e[32m"
11   RED="\e[39m"
12   NORMAL="\e[0m"
13 }
14
15
16 function line {
17   echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
18 }
19
20
21 function show_whitelist {
22         line
23         cat $HOME/massa/massa-node/base_config/bootstrap_whitelist.json
24         line
25 }
26
27
28 function add_to_whitelist {
29         read -r -p "Введите адрес ноды которую будем прикуривать:" NeedBootstrapIP
30         echo $(${CLI} node_bootstrap_whitelist add $NeedBootstrapIP)
31         line
32         echo "IP $NeedBootstrapIP добавлен в whitelist"
33         show_whitelist
34 }
35
36 CLI="$HOME/massa/massa-client/./massa-client --pwd ${massa_pass}"
37
38 clear
39 colors
40 cd $HOME/massa/massa-client/
41 add_to_whitelist