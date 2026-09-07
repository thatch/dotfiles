#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  exec sudo "$0" "$@"
fi

if ! id claude >/dev/null 2>&1; then
  echo "error: user 'claude' does not exist; not installing udev rules" >&2
  exit 1
fi

install -m 0644 \
  "$DOTFILES_DIR/system/etc/udev/rules.d/99-claude-stm32-perms.rules" \
  "/etc/udev/rules.d/99-claude-stm32-perms.rules"

udevadm control --reload-rules
udevadm trigger

echo "installed /etc/udev/rules.d/99-claude-stm32-perms.rules"
