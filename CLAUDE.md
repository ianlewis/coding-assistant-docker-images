# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains secure Docker images for various code assistants, including **OpenCode** and **Claude Code**. The primary focus is providing locked-down containerized environments that allow code assistants to run securely without compromising the host system.

## Architecture

### Two Main Images
- **opencode/**: Contains the OpenCode AI assistant (opencode-ai package)
- **claude-code/**: Contains the Claude Code assistant (@anthropic-ai/claude-code package)

### Security Features
- Based on Node.js 22.17.0 slim image with pinned SHA256 digest
- Runs with restricted permissions using `gosu`
- Designed to work with gVisor (runsc) for additional sandboxing
- All package versions are pinned with specific version numbers

### Directory Structure
- `/workspace`: Working directory mounted from host
- `/local`: Persistent storage for agent data
- `/app`: Application installation directory

## Common Development Commands

### Building Images
```bash
# Build OpenCode image
make opencode-docker

# Build Claude Code image  
make claude-code-docker
```

### Running Agents
```bash
# Run OpenCode agent
make run-opencode

# Run Claude Code agent
make run-claude-code
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

# Install dependencies
npm install --package-lock-only
```

## Code Style Requirements

- **Indentation**: 2 spaces for JSON/YAML, 4 spaces for Markdown, tabs for Makefiles
- **Line endings**: Unix-style (LF) with final newline
- **Encoding**: UTF-8
- **License headers**: Apache 2.0 required on all source files
- **Shell scripts**: Use `#!/usr/bin/env bash` with `set -euo pipefail`
- **Error handling**: Proper error handling required in all scripts

## Security Considerations

- All Dockerfiles use pinned base images with SHA256 digests
- Package versions are explicitly pinned
- Images are designed to run with minimal privileges
- Support for gVisor runtime for additional isolation
- No network access required for basic operation

## Testing

The repository uses GitHub Actions for CI/CD with comprehensive linting and security checks. All changes must pass:
- Multiple linters (markdownlint, yamllint, textlint, actionlint, hadolint, zizmor)
- License header validation
- Security scanning
- Build verification

## Important Notes

- This is a infrastructure/tooling repository focused on containerized code assistants
- Both images share similar base configuration but serve different AI assistants
- Security is a primary concern - all changes should maintain the locked-down nature
- The images are published to `ghcr.io/ianlewis/opencode` and `ghcr.io/ianlewis/claude-code`