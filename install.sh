#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=(claude zsh vim tmux)

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
        stow -t ~ "$package"
    fi
done

if [[ "$UNINSTALL" == true ]]; then
    info "Done! Packages uninstalled."
else
    info "Done! Packages linked to ~/"
fi
