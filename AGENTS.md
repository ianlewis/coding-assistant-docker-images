# Agent Guidelines

This repository contains secure Docker images for code assistants, including
opencode and Claude Code.

## Architecture

- `opencode/` contains the opencode AI assistant image.
- `claude-code/` contains the Claude Code assistant image.
- Both images use a secure base image and are designed to run with restricted
  permissions and gVisor (`runsc`) for additional isolation.
- `/workspace` is the working directory mounted from the host.
- Agent data is persisted under `~/.local/share/opencode-docker/` for opencode
  and `~/.local/share/claude-code-docker/` for Claude Code.

For instructions on development, coding style, testing, and project tooling,
see [CONTRIBUTING.md](CONTRIBUTING.md).
