#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link_one() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ "$(readlink "$dest" 2>/dev/null || true)" = "$src" ]; then
      echo "ok: $dest -> $src"
      return
    fi
    local backup="$dest.backup.$(date +%Y%m%d%H%M%S)"
    echo "backup: $dest -> $backup"
    mv "$dest" "$backup"
  fi

  echo "link: $dest -> $src"
  ln -s "$src" "$dest"
}

ensure_git_repo() {
  local url="$1"
  local dest="$2"

  if [ -d "$dest/.git" ]; then
    echo "update: $dest"
    git -C "$dest" pull --ff-only
    return
  fi

  if [ -e "$dest" ]; then
    echo "skip: $dest exists but is not a git checkout"
    return
  fi

  echo "clone: $url -> $dest"
  mkdir -p "$(dirname "$dest")"
  git clone "$url" "$dest"
}

link_one "$DOTFILES_DIR/home/bashrc" "$HOME/.bashrc"
link_one "$DOTFILES_DIR/home/zshrc" "$HOME/.zshrc"
link_one "$DOTFILES_DIR/home/vimrc" "$HOME/.vimrc"
link_one "$DOTFILES_DIR/home/tmux.conf" "$HOME/.tmux.conf"

link_one "$DOTFILES_DIR/home/local/bin/pbcopy" "$HOME/.local/bin/pbcopy"
link_one "$DOTFILES_DIR/home/local/bin/pbpaste" "$HOME/.local/bin/pbpaste"
link_one "$DOTFILES_DIR/home/local/bin/copy-url-from-pane" "$HOME/.local/bin/copy-url-from-pane"
link_one "$DOTFILES_DIR/home/local/bin/newagent" "$HOME/.local/bin/newagent"
link_one "$DOTFILES_DIR/home/local/share/dotfiles/shell-config.sh" "$HOME/.local/share/dotfiles/shell-config.sh"
link_one "$DOTFILES_DIR/home/local/share/dotfiles/git-completion.sh" "$HOME/.local/share/dotfiles/git-completion.sh"

link_one "$DOTFILES_DIR/home/config/ghostty/config" "$HOME/.config/ghostty/config"
link_one "$DOTFILES_DIR/home/config/xfce4/terminal/terminalrc" "$HOME/.config/xfce4/terminal/terminalrc"

link_one "$DOTFILES_DIR/home/pi/agent/AGENTS.md" "$HOME/.pi/agent/AGENTS.md"
link_one "$DOTFILES_DIR/home/pi/agent/extensions/style-md.ts" "$HOME/.pi/agent/extensions/style-md.ts"
link_one "$DOTFILES_DIR/home/pi/agent/skills/skel" "$HOME/.pi/agent/skills/skel"

link_one "$DOTFILES_DIR/home/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link_one "$DOTFILES_DIR/home/claude/style.md" "$HOME/.claude/style.md"

ensure_git_repo \
  "https://github.com/mgedmin/coverage-highlight.vim.git" \
  "$HOME/.vim/pack/vendor/start/coverage-highlight.vim"
