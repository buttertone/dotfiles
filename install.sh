#!/usr/bin/env bash
# Symlink dotfiles into $HOME. Safe to re-run: correct links are left alone,
# anything else in the way is moved to ~/.dotfiles-backup/<timestamp>/.
#
# Deliberately does nothing but symlink, so it works on machines where we
# can't install packages. Must run under macOS's stock bash 3.2.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0

# Each machine links only the groups it needs, e.g.
#   ./install.sh bash iterm2
#   ./install.sh bash tmux emacs claude
ALL_GROUPS="bash tmux emacs claude iterm2"
SELECTED=""

usage() {
  echo "usage: $0 [-n|--dry-run] [group ...]"
  echo "groups: $ALL_GROUPS (default: all)"
}

while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    bash|tmux|emacs|claude|iterm2) SELECTED="$SELECTED $1" ;;
    *) usage >&2; exit 2 ;;
  esac
  shift
done
[ -n "$SELECTED" ] || SELECTED=$ALL_GROUPS

run() {
  if [ "$DRY_RUN" -eq 1 ]; then echo "        would: $*"; else "$@"; fi
}

# link <path in repo> <path under $HOME>
link() {
  local src="$DOTFILES/$1" dst="$HOME/$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "ok      ~/$2"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    echo "backup  ~/$2 -> $BACKUP_DIR/$2"
    run mkdir -p "$(dirname "$BACKUP_DIR/$2")"
    run mv "$dst" "$BACKUP_DIR/$2"
  fi
  echo "link    ~/$2"
  run mkdir -p "$(dirname "$dst")"
  run ln -s "$src" "$dst"
}

for group in $SELECTED; do
  case "$group" in
    bash)
      link bash/bash_profile     .bash_profile
      link bash/bashrc           .bashrc
      ;;
    tmux)
      link tmux/tmux.conf        .config/tmux/tmux.conf
      ;;
    emacs)
      # Link the files, not the directory, so Emacs caches and straight.el's
      # package checkouts stay out of the repo.
      link emacs/early-init.el   .emacs.d/early-init.el
      link emacs/init.el         .emacs.d/init.el
      ;;
    claude)
      link claude/settings.json  .claude/settings.json
      ;;
    iterm2)
      # iTerm2 loads every profile in this directory and reloads on change.
      # Skip where iTerm2 has never run, so Linux boxes don't grow ~/Library.
      if [ -d "$HOME/Library/Application Support/iTerm2" ]; then
        link iterm2/dev.json "Library/Application Support/iTerm2/DynamicProfiles/dev.json"
      else
        echo "skip    iterm2 (no ~/Library/Application Support/iTerm2)"
      fi
      ;;
  esac
done
