#!/usr/bin/env bash
#
# Copyright 2025 Ian Lewis
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

# Log function for better visibility
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# NOTE: USER_ID,GROUP_ID set in entrypoint.sh
user_home=$(getent passwd "${USER_ID}" | cut -d: -f6)
if [ -z "$user_home" ]; then
    log "ERROR: User home directory not found."
    exit 1
fi

log "Creating symlinks in user home directory: ${user_home}"
ln -sf /local "${user_home}/.local"
