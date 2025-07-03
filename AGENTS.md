# Agent Guidelines

## Build/Test/Lint Commands

- **Format all files**: `make format`
- **Run all linters**: `make lint`
- **Individual linters**: `make markdownlint`, `make yamllint`, `make textlint`, `make actionlint`, `make hadolint`, `make zizmor`
- **License headers**: `make license-headers`
- **Check TODOs**: `make todos`
- **Clean temporary files**: `make clean`

## Code Style Guidelines

- **Indentation**: Use spaces (2 for JSON/YAML, 4 for Markdown, tabs for Makefiles)
- **Line endings**: Unix-style (LF) with final newline
- **Encoding**: UTF-8
- **Trailing whitespace**: Remove all trailing whitespace
- **Markdown**: Use dash-style unordered lists, 4-space indentation, fenced code blocks with backticks
- **YAML**: Follow yamllint rules, disable line-length checks
- **Shell scripts**: Use `#!/usr/bin/env bash`, `set -euo pipefail`, proper error handling
- **Comments**: Single space from content in YAML
- **License headers**: Apache 2.0 license required on all source files

## Error Handling

- Always use proper error handling in shell scripts
- Follow existing patterns for logging and error reporting
- Respect `.gitignore` and don't cross git submodule boundaries
