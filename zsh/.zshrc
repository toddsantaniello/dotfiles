# Basic PATH configuration
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.git-scripts"

# Add Homebrew
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Add your PostgreSQL and Mint paths
# export PATH="/opt/homebrew/opt/libpq/bin:$HOME/.mint/bin:$PATH"
# export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Created by Zap installer
if [ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ]; then
    source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
    plug "zsh-users/zsh-autosuggestions"
    plug "zap-zsh/supercharge"
    plug "zap-zsh/zap-prompt"
    # Show only the branch: the theme's dirty/untracked checks scan the whole
    # working tree on every prompt, which is slow in big repos
    zstyle -d ':vcs_info:git*+set-message:*' hooks
    zstyle ':vcs_info:*' check-for-changes false
    plug "zsh-users/zsh-syntax-highlighting"
    plug "chivalryq/git-alias"
fi

# Load and initialise completion system
autoload -Uz compinit
compinit

# Basic aliases
alias ls='ls -alF --color=auto'

# eval "$(starship init zsh)"

# bun
if [ -d "$HOME/.bun" ]; then
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    [ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
fi

# ADB
if [ -d "$HOME/Library/Android/sdk/platform-tools" ]; then
    export ANDROID_TOOLS="$HOME/Library/Android/sdk/platform-tools"
    export PATH="$ANDROID_TOOLS:$PATH"
fi

# Machine/work-specific config (not tracked in dotfiles)
if [[ -f ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/todd/.docker/completions $fpath)
autoload -Uz compinit
(( ${+_comps[docker]} )) || compinit
# End of Docker CLI completions
