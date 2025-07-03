# Code Assistant Docker Images

[![tests](https://github.com/ianlewis/coding-assistant-docker-images/actions/workflows/pre-submit.units.yml/badge.svg)](https://github.com/ianlewis/coding-assistant-docker-images/actions/workflows/pre-submit.units.yml)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/ianlewis/coding-assistant-docker-images/badge)](https://securityscorecards.dev/viewer/?uri=github.com%2Fianlewis%2Fcoding-assistant-docker-images)

This repository contains Docker images for various code assistants. The
intention is to provide a locked-down environment for coding assistants that
allow them to be run in a secure manner that won't be able to do damage to the
host system.

## opencode

The [opencode](https://github.com/sst/opencode) image can be run with the
following commands. The local state is stored in
`~/.local/share/opencode-docker`.

```bash
XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
mkdir -p "${XDG_DATA_HOME}/opencode-docker"
docker run \
    --rm \
    --interactive \
    --tty \
    --name opencode \
    --volume "$(pwd):/workspace" \
    --volume "${XDG_DATA_HOME}/opencode-docker:/local" \
    "ghcr.io/ianlewis/opencode-docker"
```
