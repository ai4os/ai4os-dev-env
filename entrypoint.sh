#!/bin/bash
# Entrypoint script to update INFO.md and then execute CMD command (e.g. deep-start)

set -e

# update INFO.md from remote URL
curl -o /srv/INFO.md.remote https://raw.githubusercontent.com/ai4os/ai4os-dev-env/main/INFO.md
[[ $? -eq 0 ]] && mv /srv/INFO.md.remote /srv/INFO.md

exec "$@"
