# Code Assistant Docker Images

[![tests](https://github.com/ianlewis/coding-assistant-docker-images/actions/workflows/pre-submit.units.yml/badge.svg)](https://github.com/ianlewis/coding-assistant-docker-images/actions/workflows/pre-submit.units.yml)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/ianlewis/coding-assistant-docker-images/badge)](https://securityscorecards.dev/viewer/?uri=github.com%2Fianlewis%2Fcoding-assistant-docker-images)

This repository contains Docker images for various code assistants. The
intention is to provide a locked-down environment for coding assistants that
allow them to be run in a secure manner that won't be able to do damage to the
host system.

## `opencode`

The [`opencode`](https://github.com/sst/opencode) image can be run with the
following commands. The local state is stored in
`~/.local/share/opencode-docker`.

```bash
OPENCODE_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/opencode-docker"
mkdir -p "${OPENCODE_DATA_HOME}"
docker run \
    --rm \
    --interactive \
    --tty \
    --name opencode \
    --volume "$(pwd):/workspace" \
    --volume "${OPENCODE_DATA_HOME}:/local" \
    "ghcr.io/ianlewis/opencode"
```

Run with [gVisor](https://gvisor.dev/) for additional security. This requires
`runsc` to be [installed and
configured](https://gvisor.dev/docs/user_guide/install/) as a runtime for
Docker:

```bash
OPENCODE_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/opencode-docker"
mkdir -p "${OPENCODE_DATA_HOME}"
docker run \
    --rm \
    --interactive \
    --tty \
    --name opencode \
    --runtime runsc \
    --volume "$(pwd):/workspace" \
    --volume "${OPENCODE_DATA_HOME}:/local" \
    "ghcr.io/ianlewis/opencode"
```

## `claude-code`

The [`claude-code`](https://github.com/anthropics/claude-code) image can be run with the
following commands. The local state is stored in
`~/.local/share/claude-code-docker`.

```bash
CLAUDE_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/claude-code-docker"
mkdir -p "${CLAUDE_DATA_HOME}"; \
# Ensure the .claude.json file exists, as we need to bind mount it into the
# container.
if [ ! -f "${CLAUDE_DATA_HOME}/claude.json" ]; then \
    echo "{}" > "${CLAUDE_DATA_HOME}/claude.json"; \
fi; \
docker run \
    --rm \
    --interactive \
    --tty \
    --name claude-code \
    --volume "$(pwd):/workspace" \
    --volume "${CLAUDE_DATA_HOME}/claude.json:/claude.json" \
    --volume "${CLAUDE_DATA_HOME}/claude" \
    "ghcr.io/ianlewis/claude-code"
```

Run with [gVisor](https://gvisor.dev/) for additional security. This requires
`runsc` to be [installed and
configured](https://gvisor.dev/docs/user_guide/install/) as a runtime for
Docker:

```bash
CLAUDE_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/claude-code-docker"
mkdir -p "${CLAUDE_DATA_HOME}"; \
# Ensure the .claude.json file exists, as we need to bind mount it into the
# container.
if [ ! -f "${CLAUDE_DATA_HOME}/claude.json" ]; then \
    echo "{}" > "${CLAUDE_DATA_HOME}/claude.json"; \
fi; \
docker run \
    --rm \
    --interactive \
    --tty \
    --name claude-code \
    --runtime runsc \
    --volume "$(pwd):/workspace" \
    --volume "${CLAUDE_DATA_HOME}/claude.json:/claude.json" \
    --volume "${CLAUDE_DATA_HOME}:/claude" \
    "ghcr.io/ianlewis/claude-code"
```
