# Git completion helpers shared by bash and zsh.
# Source this from ~/.bashrc or ~/.zshrc.

# Convenient short commands whose arguments complete to git refs/branches.
alias gco='git checkout'
alias gsw='git switch'
alias gb='git branch'
alias gbd='git branch -d'
alias gm='git merge'
alias grb='git rebase'

_dotfiles_git_local_branches() {
  git for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null
}

_dotfiles_git_all_branches() {
  {
    git for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null
    git for-each-ref --format='%(refname:short)' refs/remotes 2>/dev/null | grep -vE '/HEAD$'
  } | sort -u
}

if [ -n "${BASH_VERSION:-}" ]; then
  # Prefer the full git completion shipped by git/bash-completion when present.
  if ! declare -F __git_complete >/dev/null 2>&1; then
    for f in \
      /usr/share/bash-completion/completions/git \
      /usr/share/git/completion/git-completion.bash \
      /etc/bash_completion.d/git \
      /opt/homebrew/etc/bash_completion.d/git-completion.bash \
      /usr/local/etc/bash_completion.d/git-completion.bash
    do
      [ -r "$f" ] && . "$f" && break
    done
  fi

  if declare -F __git_complete >/dev/null 2>&1; then
    __git_complete gco _git_checkout
    __git_complete gsw _git_switch
    __git_complete gb _git_branch
    __git_complete gbd _git_branch
    __git_complete gm _git_merge
    __git_complete grb _git_rebase
  else
    # Small fallback: branch/ref completion for the aliases above.
    _dotfiles_git_branch_complete_bash() {
      local cur
      cur="${COMP_WORDS[COMP_CWORD]}"
      COMPREPLY=( $(compgen -W "$(_dotfiles_git_all_branches)" -- "$cur") )
    }
    complete -F _dotfiles_git_branch_complete_bash gco gsw gb gbd gm grb
  fi
fi

if [ -n "${ZSH_VERSION:-}" ]; then
  # macOS zsh has git completion built in; make sure completion is initialized.
  autoload -Uz compinit
  if [ -d "${ZDOTDIR:-$HOME}/.zcompdump" ]; then
    compinit
  else
    compinit -d "${ZDOTDIR:-$HOME}/.zcompdump"
  fi

  if whence -w _git >/dev/null 2>&1; then
    compdef _git gco=git-checkout
    compdef _git gsw=git-switch
    compdef _git gb=git-branch
    compdef _git gbd=git-branch
    compdef _git gm=git-merge
    compdef _git grb=git-rebase
  else
    _dotfiles_git_branch_complete_zsh() {
      local -a branches
      branches=( ${(f)"$(_dotfiles_git_all_branches)"} )
      _describe 'git branches' branches
    }
    compdef _dotfiles_git_branch_complete_zsh gco gsw gb gbd gm grb
  fi
fi
