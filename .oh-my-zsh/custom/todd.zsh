# You can put files here to add functionality separated per file, which
# will be ignored by git.
# Files on the custom/ directory will be automatically loaded by the init
# script, in alphabetical order.

# For example: add yourself some shortcuts to projects you often work on.
#
# brainstormr=~/Projects/development/planetargon/brainstormr
# cd $brainstormr
#
export JRE_HOME=/Applications/Android\ Studio.app/Contents/jre/Contents/Home
export ANDROID_HOME=/Users/toddsantaniello/Library/Android/sdk
export PATH=$JRE_HOME/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH

alias ls='ls -alF'
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
alias grw='./gradlew'
alias devdeb='./gradlew installDevDeb'
# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"
