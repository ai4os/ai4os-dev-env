#!/bin/bash
# Entrypoint script to update INFO.md and then execute CMD command (e.g. deep-start)

set -e

# Create convenience symlinks in /srv
# Home directory symlink (points to current user's home (usually root)
ln -s $HOME /srv/home 2>/dev/null || true

# External storage mount point (if exists)
[ -d /storage ] && ln -s /storage /srv/storage || true

# update INFO.md from remote URL
curl -o /srv/INFO.md.remote https://raw.githubusercontent.com/ai4os/ai4os-dev-env/main/INFO.md
[[ $? -eq 0 ]] && mv /srv/INFO.md.remote /srv/INFO.md

exec "$@"
