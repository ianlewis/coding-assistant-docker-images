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

# Command claude runs the Claude Code agent in a Docker container using the
# runsc. The current working directory is mounted into the container. Claude
# configuration is stored in the directory ${XDG_DATA_HOME}/claude-code-docker.

set -euo pipefail

function _main() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "Docker is not installed. Please install Docker first." >&2
        echo "Please see this URL for installation instructions:" >&2
        echo "Please see https://docs.docker.com/engine/install/" >&2
        exit 1
    fi

    local runsc_path
    runsc_path=$(docker system info --format '{{.Runtimes.runsc.Path}}')
    if [ -z "${runsc_path}" ]; then
        echo "runsc runtime not found. Please ensure runsc is installed and configured." >&2
        echo "Please see this URL for installation instructions:" >&2
        echo "https://gvisor.dev/docs/user_guide/quick_start/docker/" >&2
        exit 1
    fi

    if ! command -v cosign >/dev/null 2>&1; then
        echo "cosign is not installed. Please install cosign first." >&2
        echo "Please see this URL for installation instructions:" >&2
        echo "https://docs.sigstore.dev/cosign/system_config/installation/" >&2
        exit 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        echo "jq is not installed. Please install jq first." >&2
        echo "Please see this URL for installation instructions:" >&2
        echo "https://jqlang.org/download/" >&2
        exit 1
    fi

    CLAUDE_CODE_IMAGE=${CLAUDE_CODE_IMAGE:-"ghcr.io/ianlewis/claude-code"}

    XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
    CLAUDE_DATA_HOME="${XDG_DATA_HOME}/claude-code-docker"

    mkdir -p "${CLAUDE_DATA_HOME}"

    # Ensure the .claude.json file exists, as we need to bind mount it into the
    # container.
    if [ ! -f "${CLAUDE_DATA_HOME}/claude.json" ]; then
        echo "{}" >"${CLAUDE_DATA_HOME}/claude.json"
    fi

    local verified_sha
    verified_sha=$(cosign verify-attestation \
        --type slsaprovenance \
        --certificate-oidc-issuer https://token.actions.githubusercontent.com \
        --certificate-identity-regexp '^https://github.com/slsa-framework/slsa-github-generator/.github/workflows/generator_container_slsa3.yml@refs/tags/v[0-9]+.[0-9]+.[0-9]+$' \
        --policy ~/.config/coding-assistant-docker-images/policy.cue \
        "${CLAUDE_CODE_IMAGE}" | jq -r '.payload' | base64 -d | jq -r '.subject[0].digest.sha256')

    if [ -z "${verified_sha}" ]; then
        echo "Failed to verify the image signature." >&2
        exit 1
    fi

    echo "Verified image: ${CLAUDE_CODE_IMAGE}:sha256:${verified_sha}"

    # Ensure we have the latest image
    docker pull "${CLAUDE_CODE_IMAGE}@sha256:${verified_sha}"

    docker run \
        --rm \
        --interactive \
        --tty \
        --runtime runsc \
        --volume "$(pwd):/workspace" \
        --volume "${CLAUDE_DATA_HOME}/claude.json:/claude.json" \
        --volume "${CLAUDE_DATA_HOME}:/claude" \
        "${CLAUDE_CODE_IMAGE}@sha256:${verified_sha}" claude "$@"
}

_main "$@"
