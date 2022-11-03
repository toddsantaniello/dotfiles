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
alias devdeb='./gradlew installDevDeb'
alias gsquash='_gsquash'
alias gbdlocals='_gbdlocals'
alias gitrmlocal="!f() { git branch | egrep -v \"(^\*|master|dev)\" | egrep $1"

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

_gsquash() {
  if [ "$1" != "" ]
  then
    git rebase -i HEAD~$1
  else
    echo "add how many commits you want to squash"
  fi
}

_gbdlocals() {
  if [ "$1" != "" ]
  then
    git branch | egrep -v "(^\*|master|dev)" | egrep $1 | command xargs -n 1 git branch -D
  else
    echo "add a starting string for deletion"
  fi
}
