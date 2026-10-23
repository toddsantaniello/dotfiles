#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=(agents claude git zsh vim tmux ghostty)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; }

if ! command -v stow &> /dev/null; then
    warn "GNU Stow not found. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install stow
    else
        error "Homebrew not found. Install stow manually: https://www.gnu.org/software/stow/"
        exit 1
    fi
fi

UNINSTALL=false
SELECTED_PACKAGES=()

for arg in "$@"; do
    if [[ "$arg" == "--uninstall" || "$arg" == "-u" ]]; then
        UNINSTALL=true
    else
        SELECTED_PACKAGES+=("$arg")
    fi
done

if [[ ${#SELECTED_PACKAGES[@]} -eq 0 ]]; then
    SELECTED_PACKAGES=("${PACKAGES[@]}")
fi

cd "$DOTFILES_DIR"

# Move aside real files that would block stow. Targets that already resolve
# into the dotfiles repo (e.g. inside a folded directory symlink) are left alone.
backup_conflicts() {
    local package="$1" rel target
    while IFS= read -r -d '' rel; do
        rel="${rel#./}"
        target="$HOME/$rel"
        if [[ -e "$target" && ! -L "$target" ]] && [[ "$(realpath "$target")" != "$DOTFILES_DIR"/* ]]; then
            local backup="$target.bak.$(date +%Y%m%d%H%M%S)"
            warn "Backing up existing $target -> $backup"
            mv "$target" "$backup"
        fi
    done < <(cd "$package" && find . \( -type f -o -type l \) -print0)
}

# A real ~/.agents/skills keeps stow from folding it into the repo, so skill
# installers (npx skills, pfw) write into ~ instead of into git.
mkdir -p ~/.agents/skills

for package in "${SELECTED_PACKAGES[@]}"; do
    if [[ ! -d "$package" ]]; then
        error "Package '$package' not found"
        continue
    fi

    if [[ "$UNINSTALL" == true ]]; then
        info "Unstowing $package..."
        stow -D -t ~ "$package"
    else
        info "Stowing $package..."
        backup_conflicts "$package"
        stow -t ~ "$package"
    fi
done

# Point each harness at the shared ~/AGENTS.md and ~/.agents/skills. These are
# made here rather than stowed: a link stowed from the repo resolves relative to
# the repo, not to ~.
harness_links=(
    "../AGENTS.md:$HOME/.claude/CLAUDE.md"
    "../.agents/skills:$HOME/.claude/skills"
    "../AGENTS.md:$HOME/.codex/AGENTS.md"
)
if [[ " ${SELECTED_PACKAGES[*]} " == *" agents "* ]]; then
    for entry in "${harness_links[@]}"; do
        target="${entry%%:*}" link="${entry#*:}"
        if [[ "$UNINSTALL" == true ]]; then
            [[ -L "$link" ]] && rm "$link"
            continue
        fi
        mkdir -p "$(dirname "$link")"
        if [[ -e "$link" && ! -L "$link" ]]; then
            backup="$link.bak.$(date +%Y%m%d%H%M%S)"
            warn "Backing up existing $link -> $backup"
            mv "$link" "$backup"
        fi
        info "Linking $link -> $target"
        ln -sfn "$target" "$link"
    done
fi

# Zap plugin manager for zsh. --keep stops the installer from replacing the
# stowed .zshrc.
ZAP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zap"
if [[ "$UNINSTALL" == false && " ${SELECTED_PACKAGES[*]} " == *" zsh "* && ! -d "$ZAP_DIR" ]]; then
    info "Installing Zap..."
    zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1 --keep
fi

if [[ "$UNINSTALL" == true ]]; then
    info "Done! Packages uninstalled."
else
    info "Done! Packages linked to ~/"
fi
