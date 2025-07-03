# Agent Guidelines for OpenCode Docker Environment

## Project Structure
This is a Docker-based development environment for the OpenCode AI tool with Node.js and Go support.

## Build/Test Commands
- No specific build/lint/test scripts defined in package.json
- The project uses `opencode-ai` package (v0.1.174) as the main dependency
- Docker build: `docker build -t opencode .`
- Run container: `docker run -v $(pwd):/workspace opencode`

## Code Style Guidelines
- **License Headers**: Include Apache 2.0 license headers in all files (see Dockerfile:1-13)
- **Shell Scripts**: Use `set -euo pipefail` for error handling and strict mode
- **Logging**: Use structured logging with timestamps (see entrypoint.sh:6-8)
- **Comments**: Add descriptive comments for complex logic
- **Error Handling**: Implement proper error checking and validation
- **Security**: Use gosu for privilege dropping, validate user inputs

## Environment
- Base: Node.js 22.17.0-slim with Go 1.24.4 and gopls 0.19.1
- Working directory: /workspace
- Entry point handles user ID/group ID mapping for file permissions
- Supports both root and non-root execution contexts