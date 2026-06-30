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
for t in tmux rg fzf; do
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
clone_plugin "Aloxaf/fzf-tab"                    "fzf-tab"

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

# 5b. Interactive bash -> zsh handoff. Coder's web terminal and VS Code/Cursor
#     terminals start /bin/bash (ignoring the login shell), so they'd otherwise
#     miss this whole zsh setup. This flips them to zsh.
if ! grep -q 'exec zsh' "$HOME/.bashrc" 2>/dev/null; then
  cat >> "$HOME/.bashrc" <<'BASHRC'

# switch interactive bash -> zsh (web/VSCode terminals default to bash)
if [[ $- == *i* ]] && command -v zsh >/dev/null 2>&1 && [[ -z $ZSH_VERSION ]]; then
  exec zsh
fi
BASHRC
  info "added bash -> zsh handoff to ~/.bashrc"
fi

# 6. Neovim — install to user space if the image doesn't provide it (no sudo).
#    Version pinned via $NVIM_VERSION (default: stable); archive checksum-verified
#    against the release's published .sha256sum before extracting.
install_neovim() {
  command -v nvim >/dev/null 2>&1 && return 0
  command -v curl >/dev/null 2>&1 || { warn "curl missing — cannot install neovim"; return 0; }
  local ver="${NVIM_VERSION:-stable}"
  local base="https://github.com/neovim/neovim/releases/download/$ver"
  local tmp asset=""
  tmp="$(mktemp -d)"
  # --connect-timeout so a network that blocks the GitHub release CDN fails fast
  # (default curl connect timeout is 300s) instead of hanging the whole install.
  local CURL="curl -fsSL --connect-timeout 20 --retry 2"
  for a in nvim-linux-x86_64.tar.gz nvim-linux64.tar.gz; do
    if $CURL -o "$tmp/nvim.tar.gz" "$base/$a"; then asset="$a"; break; fi
  done
  if [ -z "$asset" ]; then warn "neovim download failed/unreachable ($ver) — skipping (image should ship neovim)"; rm -rf "$tmp"; return 0; fi
  if $CURL -o "$tmp/sum" "$base/$asset.sha256sum"; then
    if ! ( cd "$tmp" && printf '%s  nvim.tar.gz\n' "$(cut -d' ' -f1 sum)" | sha256sum -c - >/dev/null 2>&1 ); then
      warn "neovim checksum MISMATCH — aborting nvim install"; rm -rf "$tmp"; return 0
    fi
    info "neovim checksum verified"
  else
    warn "no published checksum for $ver — installing unverified"
  fi
  tar -xzf "$tmp/nvim.tar.gz" -C "$tmp"
  local dir; dir="$(find "$tmp" -maxdepth 1 -type d -name 'nvim-linux*' | head -1)"
  [ -n "$dir" ] || { warn "neovim archive layout unexpected — skipping"; rm -rf "$tmp"; return 0; }
  mkdir -p "$HOME/.local/bin"
  rm -rf "$HOME/.local/nvim"
  mv "$dir" "$HOME/.local/nvim"
  ln -sfn "$HOME/.local/nvim/bin/nvim" "$HOME/.local/bin/nvim"
  rm -rf "$tmp"
  info "neovim $ver installed to ~/.local/nvim (on ~/.local/bin)"
}
install_neovim
export PATH="$HOME/.local/bin:$PATH"

# 7. Pre-install Neovim plugins so the first interactive launch is fast (non-fatal)
if command -v nvim >/dev/null 2>&1; then
  info "Syncing Neovim plugins (first run only)"
  nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 || warn "nvim plugin sync skipped — will install on first launch."
fi

info "Done. Open a new zsh shell."
