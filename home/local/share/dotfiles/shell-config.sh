# Shared shell config for bash/zsh.

# User-local scripts.
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# Use system trust store for tools that otherwise ship their own CA bundle.
export UV_SYSTEM_CERTS=1
export REQUESTS_CA_BUNDLE=/etc/ssl/cert.pem

export EDITOR=vim

# GNU ls color, without breaking BSD/macOS ls.
if ls --color=auto >/dev/null 2>&1; then
  alias ls='ls --color=auto'
elif ls -G >/dev/null 2>&1; then
  alias ls='ls -G'
fi

# Reuse ssh-agent started by `newagent`.
[ -r "$HOME/.ssh/agent-config.sh" ] && . "$HOME/.ssh/agent-config.sh" >/dev/null
