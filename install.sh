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

merge_json() {
  # Settings files like ~/.claude/settings.json mix machine-specific state
  # (env vars, enabled plugins) with portable preferences, so they can't be
  # symlinked wholesale like the other dotfiles -- instead, merge just the
  # keys in $src on top of whatever's already at $dest, leaving the rest.
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"
  if [ ! -e "$dest" ]; then
    echo "create: $dest"
    cp "$src" "$dest"
    return
  fi

  if jq -e --slurpfile new "$src" '. as $old | ($old * $new[0]) == $old' "$dest" >/dev/null 2>&1; then
    echo "ok: $dest already has $src's settings"
    return
  fi

  echo "merge: $src -> $dest"
  local tmp
  tmp="$(mktemp)"
  if ! jq -s '.[0] * .[1]' "$dest" "$src" > "$tmp"; then
    rm -f "$tmp"
    echo "error: jq merge failed, leaving $dest untouched" >&2
    return 1
  fi
  mv "$tmp" "$dest"
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

link_one "$DOTFILES_DIR/home/local/bin/git-co-upstream-pr" "$HOME/.local/bin/git-co-upstream-pr"
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
link_one "$DOTFILES_DIR/home/claude/commit-style.md" "$HOME/.claude/commit-style.md"
merge_json "$DOTFILES_DIR/home/claude/claude-settings.json" "$HOME/.claude/settings.json"

ensure_git_repo \
  "https://github.com/mgedmin/coverage-highlight.vim.git" \
  "$HOME/.vim/pack/vendor/start/coverage-highlight.vim"
