# Path: $HOME/.config/bash/.bashrc
# Date: Mon Feb 10 CST 2020

#== time
start=$(date --utc -d"2020-01-10T05:00:00" +%s) # utc-0 5:00:00 = utc-8 12:00:00
now=$(date --utc +%s)
echo -e "\033[1;36mYou have been using linux for \033[1;33m$(($((now-start))/86400)) \033[1;36mdays"

#== bash-git
if [ -f "$HOME/.config/bash/bash-git/gitprompt.sh" ]; then
   GIT_PROMPT_ONLY_IN_REPO=1
   source $HOME/.config/bash/bash-git/gitprompt.sh
fi

#== bash-it
case $- in
  *i*) ;;
    *) return;;
esac
export BASH_IT="$HOME/.config/bash/bash-it"
export BASH_IT_THEME='font'
# font         : time + user&host + path
# primer       : time + path
# robbyrussell : path
export TODO="t"
source $BASH_IT/bash_it.sh

#== source
export BASH_DIR="$HOME/.config/bash"
source $BASH_DIR/bashrc/.default
source $BASH_DIR/bashrc/.alias
