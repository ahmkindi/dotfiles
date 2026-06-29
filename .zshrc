# ~/.zshrc — portable across local Arch machine and Coder workspaces.

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="avit"

# Add wisely — too many plugins slow shell startup.
plugins=(git golang docker-compose docker node npm zsh-autosuggestions zsh-syntax-highlighting tmux vi-mode)

# tmux autostart only on the local machine — NOT on Coder/remote-managed shells,
# where the web terminal / `coder ssh` already provide a session.
if [[ -z "$CODER" && -z "$CODER_WORKSPACE_NAME" && -z "$CODER_AGENT_URL" ]]; then
  ZSH_TMUX_AUTOSTART=true
fi

VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
VI_MODE_SET_CURSOR=true
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#696969'

# Load oh-my-zsh if installed (guarded so a bare shell still works).
[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# Node Version Manager — try common locations (Arch package, or nvm installer).
for _nvm_init in /usr/share/nvm/init-nvm.sh "$HOME/.nvm/nvm.sh"; do
  if [[ -r "$_nvm_init" ]]; then source "$_nvm_init"; break; fi
done
unset _nvm_init

# Editor — prefer nvim, fall back to vim.
if command -v nvim >/dev/null 2>&1; then
  export EDITOR='nvim'
  alias vi='nvim'
  alias vim='nvim'
else
  export EDITOR='vim'
fi

# Go
export GOPATH="$HOME/go"
export GOBIN="$HOME/go/bin"
export PATH="$GOBIN:$PATH"

# Dotfiles bare-repo alias (local machine; harmless if ~/.cfg absent).
alias config="/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME"
