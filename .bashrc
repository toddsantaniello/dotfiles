#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PATH=$PATH:$HOME/Android/Sdk/platform-tools

alias ls='ls -alF --color=auto'
alias ga='git add'
alias gl='git log'
alias gs='git status'
alias gd='git diff'
alias gdc='git diff --cached'
alias gm='git commit -m'
alias gma='git commit -am'
alias gb='git branch'
alias gc='git checkout'
alias gra='git remote add'
alias grr='git remote rm'
alias gp='git pull --rebase'
alias gcl='git clone'
alias gist='gist -pc'
alias ssh-add="eval \"$(ssh-agent -s)\";ssh-add ~/.ssh/id_rsa"
alias journalctl='journalctl -b -p 3'
PS1='[\u@\h \W]\$ '
alias start-pom="termdown 25m && aplay ~/source/loopyzort/pomodoro-timer/gong.wav"

pomodoro() {
    termdown "$1"m && aplay ~/source/loopyzort/pomodoro-timer/gong.wav
}
