#!/usr/bin/env bash

set -euo pipefail

# Log function for better visibility
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Get the user ID and group ID from the app directory
# Default to current user if the directory is owned by root (could happen in some Docker setups)
USER_ID=$(stat -c %u /workspace)
GROUP_ID=$(stat -c %g /workspace)
CONTAINER_USER_ID=${CONTAINER_USER_ID:-}

# If USER_ID is root (0), and a non-root UID is specified via environment variable, use that instead
if [ "$USER_ID" = "0" ] && [ -n "$CONTAINER_USER_ID" ] && [ "$CONTAINER_USER_ID" != "0" ]; then
    USER_ID=$CONTAINER_USER_ID
    # If GROUP_ID is not specified, make it the same as USER_ID
    GROUP_ID=${CONTAINER_GROUP_ID:-$USER_ID}
    log "Using user ID from environment variable: $USER_ID:$GROUP_ID"
fi

log "Running as user ID: ${USER_ID}, group ID: ${GROUP_ID}"

# If we're not root (could happen with custom docker run commands)
if [ "$USER_ID" != "0" ]; then
    # Create group if it doesn't exist
    if ! getent group "$GROUP_ID" >/dev/null 2>&1; then
        groupadd -g "$GROUP_ID" appuser
    fi

    # Create user if it doesn't exist
    if ! getent passwd "$USER_ID" >/dev/null 2>&1; then
        useradd -u "$USER_ID" -g "$GROUP_ID" -d /workspace -s /bin/bash appuser
    fi
fi

# Create a link from the local data directory to the user's home directory.
user_home=$(getent passwd "$USER_ID" | cut -d: -f6)
if [ -z "$user_home" ]; then
    log "ERROR: User home directory not found."
    exit 1
fi
ln -sf "${user_home}/local" "/.local"

if [ "$USER_ID" != "0" ]; then
    log "Initialization complete, launching command as UID $USER_ID: $*"
    # Use gosu to drop privileges and run the command as the app directory owner
    exec gosu "$USER_ID:$GROUP_ID" bash -c "$@"
else
    log "Initialization complete, launching command as root: $*"
    exec bash -c "$@"
fi
