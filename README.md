# dotfiles

Portable dotfiles for my local Arch machine and ephemeral [Coder](https://coder.com) workspaces.

## Use on Coder

```sh
coder dotfiles https://github.com/ahmkindi/dotfiles
```

Coder clones the repo and runs `install.sh`, which:

1. Installs **oh-my-zsh** + the `zsh-autosuggestions` / `zsh-syntax-highlighting` plugins (user-space).
2. Symlinks `.zshrc`, `.gitconfig`, `.tmux.conf`, and `nvim/` → `~/.config/nvim`.
3. Sets zsh as the default shell (best-effort) and pre-syncs Neovim plugins.

The script is **idempotent** and uses **no sudo** — base CLI tools (`zsh`, `git`, `tmux`,
`nvim`, `rg`) must be provided by the workspace image. Missing ones are warned about, not installed.

## Manual install (any machine)

```sh
git clone https://github.com/ahmkindi/dotfiles ~/dotfiles
~/dotfiles/install.sh
```

## Layout

| Path | What |
|------|------|
| `install.sh`  | Bootstrap / symlink script (run by `coder dotfiles`). |
| `.zshrc`      | zsh + oh-my-zsh. tmux autostart only off-Coder; nvm path guarded. |
| `.tmux.conf`  | tmux + vim-aware pane navigation. |
| `.gitconfig`  | git identity; per-dir override under `~/rihal/`. |
| `nvim/`       | Native Neovim config (lazy.nvim): gruvbox, treesitter, LSP, format-on-save. |
| `desktop/`    | Local Arch X11 bits (`.xinitrc`, `.Xmodmap`). **Not** used on Coder. |

## Notes

- Editor moved from LunarVim to a native Neovim config — faster to install on fresh
  workspaces and uses maintained plugins (`conform.nvim` instead of deprecated `null-ls`).
- Language servers install on demand via Mason into `~/.local/share/nvim` (no sudo).
