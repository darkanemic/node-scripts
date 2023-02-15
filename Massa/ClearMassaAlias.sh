#!/bin/bash
function alias {
  echo "alias client='cd $HOME/massa/massa-client/ && $HOME/massa/massa-client/massa-client --pwd $massa_pass && cd'" >> ~/.profile
  echo "alias clientw='cd $HOME/massa/massa-client/ && $HOME/massa/massa-client/massa-client --pwd $massa_pass && cd'" >> ~/.profile
}

sed -i '/client/d' .profile
alias
echo "Фаил .profile почищен от лишних alias."