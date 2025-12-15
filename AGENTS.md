# Agent Guidelines

This file provides guidance to Coding Agents like Claude Code (`claude.ai/code`)
when working with code in this repository.

## Project Overview

This repository contains secure Docker images for various code assistants,
including **opencode** and **Claude Code**. The primary focus is providing
locked-down containerized environments that allow code assistants to run
securely without compromising the host system.

## Architecture

### Two Main Images

- **`opencode/`**: Contains the opencode AI assistant (`opencode-ai` package)
- **`claude-code/`**: Contains the Claude Code assistant
  (`@anthropic-ai/claude-code` package)

### Security Features

- All images are built from a secure base image with pinned versions.
- Runs as a user with restricted permissions using `gosu`
- Designed to work with gVisor (`runsc`) for additional sandboxing
- All package versions are pinned with specific version numbers

### Image Directory Structure

#### Common image directory structure

- `/workspace`: Working directory mounted from host (current project directory)

#### `opencode` image directory structure

- `/local`: Persistent storage for agent data and configurations. This directory
  is mounted from the host directory `~/.local/share/opencode-docker/`. A
  symbolic link to this directory is created at `~/.local` inside the container.

#### `claude-code` image directory structure

- `/claude.json`: Claude Code configuration file. This file is bind mounted from
  `~/.local/share/claude-code-docker/claude.json`. A symbolic link to this file
  is created at `~/.claude.json` inside the container.
- `/claude`: Claude Code data directory. This file is mounted from the host
  directory `~/.local/share/claude-code-docker/`. A symbolic link to this
  directory is created at `~/.claude` inside the container.

### Base Image

All images are built on a secure base image
(`ghcr.io/ianlewis/coding-assistant-docker-images-base`) that includes:

- **Node.js**: 24.6.0-slim with pinned SHA256 digest
- **Go**: 1.24.4 with Go Language Server (`gopls` 0.19.1)
- **System packages**: `curl`, `git`, `make`, `python3`, `python3-venv`,
  `python3-pip`, `gcc`, `g++`, `gosu`
- **Security features**: Runs with restricted permissions using `gosu`, designed
  for gVisor runtime

### Dependencies & Tools

#### Package Versions (All Pinned)

- **opencode**: Uses the `opencode-ai` npm package.
- **Claude Code**: Uses the `@anthropic-ai/claude-code` npm package.
- **Development tools**: Via aqua package manager (`actionlint`, `shellcheck`,
  `jq`, `todos`, `hadolint`)
- **Linting/formatting**: `markdownlint`, `prettier`, `textlint`, `yamllint`,
  `zizmor`

## Common Development Commands

### Building Images

```bash
# Build base image (prerequisite for other images)
make base

# Build opencode image
make opencode-docker

# Build Claude Code image
make claude-code-docker
```

### Running Agents

```bash
# Run opencode agent (from source)
make run-opencode

# Run Claude Code agent (from source)
make run-claude-code
```

### Launcher Scripts

Production launcher scripts are available in `/bin/` directory:

```bash
# Install launcher scripts to ~/.local/bin
make install

# Run using installed launchers
opencode    # Runs opencode with signature verification
claude      # Runs Claude Code with signature verification
```

### Package Management

```bash
# Update package-lock.json files
make package-lock.json
```

### Code Quality

```bash
# Format all files
make format

# Run all linters
make lint

# Individual linters
make markdownlint
make yamllint
make textlint
make actionlint
make hadolint
make zizmor

# Update license headers
make license-headers

# Check for TODOs/FIXMEs
make todos
```

### Maintenance

```bash
# Clean temporary files
make clean
```

## Code Style Requirements

- **Indentation**: 2 spaces for JSON/YAML, 4 spaces for Markdown, tabs for
  Makefiles
- **Line endings**: Unix-style (LF) with final newline
- **Encoding**: UTF-8
- **License headers**: Apache 2.0 required on all source files
- **Shell scripts**: Use `#!/usr/bin/env bash` with `set -euo pipefail`
- **Error handling**: Proper error handling required in all scripts
- **Package versions**: All versions must be explicitly pinned with specific
  version numbers
- **Docker images**: Must use pinned base images with SHA256 digests

## Security Considerations

- All Dockerfiles use pinned base images with SHA256 digests
- Package versions are explicitly pinned
- Images are designed to run with minimal privileges
- Support for gVisor runtime for additional isolation
- No network access required for basic operation

## Testing

The repository uses GitHub Actions for CI/CD with comprehensive linting and
security checks. All changes must pass:

- Multiple linters (`markdownlint`, `yamllint`, `textlint`, `actionlint`,
  `hadolint`, `zizmor`)
- License header validation
- Security scanning with OpenSSF Scorecard
- Build verification
- SLSA Level 3 provenance generation for container images
- Renovate dependency updates with automated PR creation

### CI/CD Workflows

- **`pre-submit.units.yml`**: Main CI pipeline with linting and build
  verification
- **`generator-container-ossf-slsa3-publish.yml`**: SLSA Level 3 provenance
  generation
- **`schedule.scorecard.yml`**: Weekly OpenSSF security scoring
- **`schedule.stale.yml`**: Automatic stale issue management
- **`schedule.issue-reopener.yml`**: Reopens issues when dependencies are
  updated

## Configuration Management

### Tool Configuration Files

- `.aqua.yaml`: Tool version management (`actionlint`, `shellcheck`, `jq`,
  `todos`, `hadolint`)
- `.markdownlint.yaml` / `.github/template.markdownlint.yaml`: Markdown linting
  rules
- `.textlintrc.yaml`: Text linting configuration
- `.yamllint.yaml`: YAML linting rules
- `.zizmor.yml`: GitHub Actions security scanning
- `renovate.json5`: Automated dependency updates
- `config/policy.cue`: CUE policy configuration

### Data Persistence

Agent data is stored in XDG-compliant directories:

- **opencode**: `~/.local/share/opencode-docker/`
- **Claude Code**: `~/.local/share/claude-code-docker/` (includes `claude.json`)

## Development Workflow

### Using aqua for Tool Management

```bash
# Install aqua tools (automatic via make targets)
make $(AQUA_ROOT_DIR)/.installed

# Tools are available in PATH when running make targets
# Example: actionlint, shellcheck, jq, todos, hadolint
```

### Development Environment Setup

The `Makefile` handles setup of the development environment and installing of
dependencies not noted as pre-requisites in `README.md`.

`Makefile` targets should be relied on whenever possible for running development
tools. For example, the `package-lock.json` file and `node_modules` directory
will be updated by whenever `package.json` changes.

This means that dependency management tools like `npm` should be run very
rarely in practice. Key `Makefile` targets can be reviewed with `make help`.

## Troubleshooting

### Common Issues

**Image build failures:**

- Ensure base image is built first: `make base`
- Check package version pinning in Dockerfiles
- Verify SHA256 digests are current

**Runtime issues:**

- Ensure gVisor (`runsc`) runtime is installed and configured
- Check volume mount permissions for `/workspace` and data directories
- Verify Docker daemon is running with appropriate permissions

**Launcher script issues:**

- Install scripts: `make install`
- Add `~/.local/bin` to PATH: `export PATH="${HOME}/.local/bin:${PATH}"`
- Check cosign installation for signature verification

**Development tool issues:**

- Aqua tools not found: Run `make $(AQUA_ROOT_DIR)/.installed`
- Linting failures: Check specific linter configuration files
- Renovate conflicts: Review and merge dependency update PRs

## Important Notes

- This is a infrastructure/tooling repository focused on containerized code
  assistants
- Both images share similar base configuration but serve different AI assistants
- Security is a primary concern - all changes should maintain the locked-down
  nature
- The images are published to `ghcr.io/ianlewis/opencode` and
  `ghcr.io/ianlewis/claude-code`
- All Docker images are signed and include SLSA Level 3 provenance for supply
  chain security
- The repository maintains OpenSSF Scorecard rating for security best practices
- Dependency updates are automated via Renovate with comprehensive testing
- gVisor runtime (`runsc`) provides additional container isolation beyond
  standard Docker
