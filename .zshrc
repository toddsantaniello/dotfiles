source /usr/local/share/antigen/antigen.zsh
source /Users/loopyzort/.bin/tmuxinator.zsh

antigen use oh-my-zsh
antigen bundle git
antigen bundle zsh-users/zsh-syntax-highlighting
antigen theme sorin
antigen apply

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
#if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

export NVM_DIR="/Users/loopyzort/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
export ANDROID_HOME=/Users/loopyzort/source/lib/android-sdk

if [[ -z $TMUX ]]; then
  export PATH="$(brew --prefix mysql55)/bin:$PATH"
  export PATH="$PATH:/Users/loopyzort/Source/lib/android-sdk/platform-tools:/Users/loopyzort/Source/lib/android-sdk/tools:/Library/Java/JavaVirtualMachines/jdk1.7.0_60.jdk/Contents/Home/bin"
  export PATH="$PATH:/Users/loopyzort/.rbenv/shims/"
fi

alias whats-my-ip="ifconfig | grep -B 6 ' active'"
alias android-build-n-play="./gradlew clean installCyclingDebug && adb shell am start -n com.strava/.SplashActivity"
alias redis="nohup redis-server &"
alias memcache="nohup memcached &"
alias resque-jobs="QUEUE='*' bundle exec rake resque:work"
alias db:test:load='RAILS_ENV=test bundle exec rake db:schema:load'
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
alias ctag-stuff='ctags -R -f .git/tags .'
#alias sprunge="git diff | curl -F 'sprunge=<-' http://sprunge.us"
#export PS1="\n<\[\033[0;32m\]\h\[\033[0m\]> \w\n! "
alias pidcat='~/Source/lib/pidcat/pidcat.py'
alias git_clean_local='git branch --merged master | grep -v "\* master" | xargs -n 1 git branch -d'
alias reset_camera='sudo killall VDCAssistant'
alias s3cmd="s3cmd --access_key=$AWS_ACCESS_KEY_ID --secret_key=$AWS_SECRET_ACCESS_KEY --access_token=$AWS_SESSION_TOKEN"

eval "$(pyenv init -)"

