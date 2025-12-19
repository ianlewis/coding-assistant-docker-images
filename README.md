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

### `opencode`

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

## `claude-code`

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
