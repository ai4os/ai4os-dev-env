#!/bin/bash
# Entrypoint script to update INFO.md, optionally update the deep-start
# launcher, and then execute the CMD command (e.g. deep-start)

set -e

# Create convenience symlinks in /srv
# Home directory symlink (points to current user's home (usually root)
ln -s $HOME /srv/home 2>/dev/null || true

# External storage mount point (if exists)
[ -d /storage ] && ln -s /storage /srv/storage || true

# update INFO.md from remote URL
# bounded and error-tolerant: under 'set -e' a failing curl would kill the
# entrypoint, and without -f a rate-limit/error page would replace INFO.md
if curl -fsSL --max-time 15 -o /srv/INFO.md.remote \
        https://raw.githubusercontent.com/ai4os/ai4os-dev-env/main/INFO.md; then
    mv /srv/INFO.md.remote /srv/INFO.md
else
    echo "[WARNING] INFO.md fetch failed, keeping the baked-in copy"
fi

# -----------------------------------------------------------------------------
# Runtime update of the deep-start launcher
# -----------------------------------------------------------------------------
# Keeps containers built from older images aligned with the pinned deep-start
# branch, so deep-start fixes do not require re-building all image flavors.
#
# Behavior:
# - the remote VERSION is checked against the local one; the update runs only
#   when they differ ("converge" semantics: the pinned branch is the truth)
# - the new version is cloned first and swapped in only on success; the
#   previous installation is kept in /srv/.deep-start.old for rollback
# - image-specific overlays (JupyterLab workspace, see Dockerfile) are
#   re-applied from the previous installation
# - the update is error-tolerant: on any failure the container starts with
#   the baked-in version
#
# DEEP_START_UPDATE=0     disable the runtime update
# DEEP_START_UPDATE=force update without the version check (testing)
# -----------------------------------------------------------------------------
DEEP_START_DIR="/srv/.deep-start"
DEEP_START_DIR_NEW="${DEEP_START_DIR}.new"
DEEP_START_DIR_OLD="${DEEP_START_DIR}.old"
DEEP_START_REPO="https://github.com/ai4os/deep-start"
# Branch to update from. The Dockerfile sets DEEP_START_BRANCH as an ENV
# (single source of truth, shared with the baked-in clone); the value below
# is only a fallback for running the entrypoint outside the image.
DEEP_START_BRANCH="${DEEP_START_BRANCH:-v3.0.0}"

function update_deep_start()
{
    local force="${1:-}"
    local local_version remote_version
    local_version=$(cat "${DEEP_START_DIR}/VERSION" 2>/dev/null) || true

    if [[ "${force}" == "force" ]]; then
        echo "[INFO] Forced deep-start update requested (DEEP_START_UPDATE=force)"
        remote_version="force"
    else
        remote_version=$(curl -fsSL --max-time 10 \
            "https://raw.githubusercontent.com/ai4os/deep-start/${DEEP_START_BRANCH}/VERSION" 2>/dev/null) || true
        # offline or rate limited: keep the baked-in version
        [[ -z "${remote_version}" ]] && { echo "[INFO] deep-start update check skipped (remote VERSION not available)"; return 0; }
        # identical versions: nothing to do
        [[ "${remote_version}" == "${local_version}" ]] && return 0
        echo "[INFO] deep-start update available: '${local_version:-none}' -> '${remote_version}'"
    fi

    # no local installation: nothing to update in place
    [[ -d "${DEEP_START_DIR}" ]] || { echo "[WARNING] No local deep-start installation found!"; return 0; }

    # clone first: on failure the current installation stays untouched
    rm -rf "${DEEP_START_DIR_NEW}"
    if ! git clone --depth 1 -b "${DEEP_START_BRANCH}" "${DEEP_START_REPO}" "${DEEP_START_DIR_NEW}"; then
        echo "[WARNING] deep-start update aborted: could not clone ${DEEP_START_REPO} (branch ${DEEP_START_BRANCH})"
        return 0
    fi

    # swap installations, keep the previous one for rollback and overlays
    rm -rf "${DEEP_START_DIR_OLD}"
    mv "${DEEP_START_DIR}" "${DEEP_START_DIR_OLD}"
    mv "${DEEP_START_DIR_NEW}" "${DEEP_START_DIR}"

    # re-apply image-specific overlays (see Dockerfile: JupyterLab workspace)
    if ! cp "${DEEP_START_DIR_OLD}/lab/deep-workspace.json" "${DEEP_START_DIR}/lab/" 2>/dev/null; then
        echo "[WARNING] deep-start update: could not restore lab/deep-workspace.json"
    fi
    if ! jupyter lab workspaces import "${DEEP_START_DIR}/lab/deep-workspace.json" >/dev/null 2>&1; then
        echo "[WARNING] deep-start update: could not re-import the JupyterLab workspace"
    fi

    # restore the launcher symlink
    ln -sf "${DEEP_START_DIR}/deep-start.sh" /usr/local/bin/deep-start \
        || echo "[WARNING] deep-start update: could not restore the 'deep-start' symlink"

    echo "[INFO] deep-start updated (previous version kept in ${DEEP_START_DIR_OLD})"
}

# Recover from an interrupted update (e.g. the container was killed between
# the two swap steps): finish the pending swap, or restore the previous
# installation. The launcher symlink is path-based and re-created here just
# in case, so the CMD always finds a working deep-start.
if [[ ! -d "${DEEP_START_DIR}" ]]; then
    if [[ -d "${DEEP_START_DIR_NEW}" ]]; then
        mv "${DEEP_START_DIR_NEW}" "${DEEP_START_DIR}"
        echo "[WARNING] deep-start: finished an interrupted update from ${DEEP_START_DIR_NEW}"
    elif [[ -d "${DEEP_START_DIR_OLD}" ]]; then
        mv "${DEEP_START_DIR_OLD}" "${DEEP_START_DIR}"
        echo "[WARNING] deep-start: restored the previous installation from ${DEEP_START_DIR_OLD}"
    fi
fi
ln -sf "${DEEP_START_DIR}/deep-start.sh" /usr/local/bin/deep-start 2>/dev/null \
    || echo "[WARNING] deep-start: could not restore the 'deep-start' symlink"

case "${DEEP_START_UPDATE:-1}" in
    0|false|no) echo "[INFO] deep-start runtime update disabled (DEEP_START_UPDATE=${DEEP_START_UPDATE})" ;;
    force)      update_deep_start force ;;
    *)          update_deep_start ;;
esac

exec "$@"
