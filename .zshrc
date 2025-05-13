# Basic PATH configuration
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.git-scripts"

# Add Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Add your PostgreSQL and Mint paths
export PATH="/opt/homebrew/opt/libpq/bin:$HOME/.mint/bin:$PATH"

# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/zap-prompt"
plug "zsh-users/zsh-syntax-highlighting"
plug "chivalryq/git-alias"

# Load and initialise completion system
autoload -Uz compinit
compinit

# Basic aliases
alias ls='ls -alF --color=auto'
