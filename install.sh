#!/usr/bin/env bash
#
# install.sh — bootstrap dotfiles. Run automatically by `coder dotfiles`.
# Idempotent, user-space only (no sudo). Safe to re-run.
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

info() { printf '\033[1;32m[dotfiles]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[dotfiles]\033[0m %s\n' "$*" >&2; }

# 1. Sanity-check tools. The workspace image is responsible for providing these
#    (this script does NOT use sudo / install system packages).
for t in zsh git curl; do
  command -v "$t" >/dev/null 2>&1 || warn "required tool '$t' not found — add it to the workspace image."
done
for t in tmux nvim rg; do
  command -v "$t" >/dev/null 2>&1 || warn "optional tool '$t' missing — related config won't fully work."
done

# 2. oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  info "Installing oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 3. Custom zsh plugins (referenced in .zshrc)
clone_plugin() {
  local repo="$1" dest="$ZSH_CUSTOM/plugins/$2"
  if [ ! -d "$dest" ]; then
    info "Installing zsh plugin $2"
    git clone --depth 1 "https://github.com/$repo" "$dest"
  fi
}
clone_plugin "zsh-users/zsh-autosuggestions"     "zsh-autosuggestions"
clone_plugin "zsh-users/zsh-syntax-highlighting" "zsh-syntax-highlighting"

# 4. Symlink dotfiles into $HOME (backs up any existing real file)
link() {
  local src="$1" dst="$2"
  [ -e "$src" ] || { warn "missing source $src"; return; }
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
    info "backed up existing $dst"
  fi
  ln -sfn "$src" "$dst"
  info "linked ${dst/#$HOME/~}"
}

link "$DOTFILES/.zshrc"     "$HOME/.zshrc"
link "$DOTFILES/.gitconfig" "$HOME/.gitconfig"
link "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
link "$DOTFILES/nvim"       "$HOME/.config/nvim"

# 5. Make zsh the default shell (best-effort; no sudo)
if command -v zsh >/dev/null 2>&1 && [ "${SHELL:-}" != "$(command -v zsh)" ]; then
  if chsh -s "$(command -v zsh)" >/dev/null 2>&1; then
    info "default shell set to zsh"
  else
    warn "couldn't chsh to zsh (no perms). In Coder set the agent's startup shell to zsh, or add 'exec zsh' to ~/.bashrc."
  fi
fi

# 6. Pre-install Neovim plugins so the first interactive launch is fast (non-fatal)
if command -v nvim >/dev/null 2>&1; then
  info "Syncing Neovim plugins (first run only)"
  nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 || warn "nvim plugin sync skipped — will install on first launch."
fi

info "Done. Open a new zsh shell."
