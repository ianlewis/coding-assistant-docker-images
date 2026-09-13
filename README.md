# Code Assistant Docker Images

[![tests](https://github.com/ianlewis/coding-assistant-docker-images/actions/workflows/pull_request.tests.yml/badge.svg)](https://github.com/ianlewis/coding-assistant-docker-images/actions/workflows/pull_request.tests.yml)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/ianlewis/coding-assistant-docker-images/badge)](https://securityscorecards.dev/viewer/?uri=github.com%2Fianlewis%2Fcoding-assistant-docker-images)

This repository contains Docker images for various code assistants. The
intention is to provide a locked-down environment for coding assistants that
allow them to be run in a secure manner that won't be able to do damage to the
host system.

## Installation

To install the images, you can use the following command:

```bash
make install
```

This will install the launcher scripts into the `~/.local/bin` directory, which
is typically included in your `PATH`.

You can then run the images using the provided launcher scripts, such as
`opencode` or `claude`. If you don't have `~/.local/bin` in your `PATH`, you can
add it with the following command:

```bash
export PATH="${HOME}/.local/bin:${PATH}"
```

## Prerequisites

The following are required to run the images:

- [Docker](https://docs.docker.com/engine/install/): for running the container
  images
- [gVisor](https://gvisor.dev/docs/user_guide/quick_start/docker/): for
  container runtime isolation
- [`cosign`](https://docs.sigstore.dev/cosign/system_config/installation/): for
  image verification
- [`jq`](https://stedolan.github.io/jq/download/): for parsing JSON

## Usage

### `agy` (Google Antigravity CLI)

- [Homepage](https://antigravity.google/product/antigravity-cli)

Using the `agy` launcher script is recommended. This will verify and run
the latest `antigravity` image with the correct parameters. The local state is
stored in `~/.local/share/antigravity-docker`.

The launcher script will run the image with roughly the following command. The
project you wish to give access to `agy` should be mounted to `/workspace`
inside the container.

```bash
ANTIGRAVITY_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/antigravity-docker"
mkdir -p "${ANTIGRAVITY_DATA_HOME}"; \
docker run \
    --rm \
    --interactive \
    --tty \
    --runtime io.containerd.runsc.v1 \
    --volume "$(pwd):/workspace" \
    --volume "${ANTIGRAVITY_DATA_HOME}:/gemini" \
    "ghcr.io/ianlewis/antigravity"
```

### `claude` (Claude Code by Anthropic)

- [Homepage](https://www.claude.com/)

Using the `claude` launcher script is recommended. This will verify and run
the latest `claude-code` image with the correct parameters. The local state is
stored in `~/.local/share/claude-code-docker`.

The launcher script will run the image with roughly the following command. The
project you wish to give access to `claude` should be mounted to `/workspace`
inside the container.

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

### `codex` (OpenAI Codex CLI)

- [Homepage](https://learn.chatgpt.com/docs/codex/cli)

Using the `codex` launcher script is recommended. This will verify and run
the latest `codex` image with the correct parameters. The local state is
stored in `~/.local/share/codex-docker`.

The launcher script will run the image with roughly the following command. The
project you wish to give access to `codex` should be mounted to `/workspace`
inside the container.

```bash
CODEX_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/codex-docker"
mkdir -p "${CODEX_DATA_HOME}"; \
docker run \
    --rm \
    --interactive \
    --tty \
    --name codex \
    --runtime runsc \
    --volume "$(pwd):/workspace" \
    --volume "${CODEX_DATA_HOME}:/codex" \
    "ghcr.io/ianlewis/codex"
```

### `copilot` (GitHub Copilot CLI)

- [Homepage](https://github.com/features/copilot/cli)

Using the `copilot` launcher script is recommended. This will verify and run
the latest `copilot` image with the correct parameters. The local state is
stored in `~/.local/share/copilot-docker`.

The launcher script will run the image with roughly the following command. The
project you wish to give access to `copilot` should be mounted to `/workspace`
inside the container.

```bash
COPILOT_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/copilot-docker"
mkdir -p "${COPILOT_DATA_HOME}"; \
docker run \
    --rm \
    --interactive \
    --tty \
    --name copilot \
    --runtime runsc \
    --volume "$(pwd):/workspace" \
    --volume "${COPILOT_DATA_HOME}:/copilot" \
    "ghcr.io/ianlewis/copilot"
```

### `opencode` (OpenCode)

- [Homepage](https://opencode.ai/)

Using the `opencode` launcher script is recommended. This will verify and run
the latest `opencode` image with the correct parameters. The local state is
stored in `~/.local/share/opencode-docker`.

The launcher script will run the image with roughly the following command. The
project you wish to give access to `opencode` should be mounted to `/workspace`
inside the container.

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
