# `repo-template`

<!-- TODO: update badge urls -->

[![tests](https://github.com/ianlewis/repo-template/actions/workflows/pre-submit.units.yml/badge.svg)](https://github.com/ianlewis/repo-template/actions/workflows/pre-submit.units.yml) [![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/ianlewis/repo-template/badge)](https://securityscorecards.dev/viewer/?uri=github.com%2Fianlewis%2Frepo-template)

<!-- TODO: Update README contents. -->

This repository template is maintained for use in repositories under
`github.com/ianlewis`. However, it can be used as a general purpose repository
starter template.

## Goals

### Repository quality

A set of [formatters and linters](#formatting-and-linting) are maintained to
maintain repository code and configuration quality through PR checks.

### Consistency & Reproducibility

Repositories created by this template should work as consistently as possible by
minimizing issues due to conflicting installed package versions. Running
commands and tools locally should have the same result between different local
development machines and CI. Recommended language runtime versions are set via
their respective ecosystem tooling.

This template strives to minimize outside dependencies on tools and
configuration requiring only a [minimal set](#requirements) of Unix userspace
tools and language runtimes to work. Dependencies are downloaded and stored
locally inside the project directory so they don't conflict with globally
installed package versions.

### Security

In general, dependencies for tools and GitHub Actions are pinned to improved
overall project supply-chain security.

External dependencies on GitHub actions are limited to trusted actions with
good security practices (e.g. official GitHub-owned actions) to minimize
exposure to compromise via external repositories.

Versioning of formatting, linting, and other tool dependencies is done via the
`requirements.txt` and `packages.json` where possible. This is so that the
versions can be maintained and updated via dependency automation tooling. This
repository uses [Mend Renovate](https://www.mend.io/renovate/) because it
allows more flexibility in configuration than Dependabot.

See also [Recommended repository settings](#recommended-repository-settings)
for more recommended security settings.

## Requirements

This repository template is meant to be used on Linux systems. It may still
work on MacOS or Windows given a `bash` environment, but this is not tested.

In general, dependencies on outside tools should be minimized in favor of
including them as project-local dependencies.

The following language runtimes are required. It is recommended to use a tool
that can manage multiple language runtime versions such as
[`pyenv`](https://github.com/pyenv/pyenv),
[`nodenv`](https://github.com/nodenv/nodenv),
[`nvm`](https://github.com/nvm-sh/nvm), or [`asdf`](https://asdf-vm.com/). This
repository includes `.node-version` and `.python-version` files to specify the
language runtime versions to use for maximum compatibility with these tools.

- [`Node.js`]: Node.js is required to run some linters and formatters.
- [`Python`]: Python is required to run some linters and formatters.

The following tools need to be installed:

- [`git`]: For repository management.
- `awk`, `bash`, `grep`, `head`, `rm`, `sha256sum`, `uname`: Standard
  Unix tools.
- GNU `make`: For running commands.
- `curl`, `tar`, `gzip`: For extracting archives.

The following tools are automatically installed locally to the project and
don't need to be pre-installed:

- [`actionlint`]: For linting GitHub Actions workflows (installed by Aqua in
  `.aqua`).
- [`jq`]: For parsing output of some linters (installed by Aqua in `.aqua`).
- [`markdownlint`]: For linting markdown (installed in local `node_modules`).
- [`mbrukman/autogen`]: For adding license headers (vendored in `third_party`).
- [`prettier`]: For formatting markdown and YAML files (installed in local
  `node_modules`).
- [`shellcheck`]: For linting shell code in GitHub Actions workflows (installed
  by Aqua in `.aqua`).
- [`textlint`]: For spelling checks (installed in local `node_modules`).
- [`todos`]: For checking for outstanding TODOs in code (installed by Aqua in
  `.aqua`).
- [`yamllint`]: For linting YAML files (installed in local Python virtualenv
  `.venv`).
- [`zizmor`]: For linting GitHub Actions workflows (installed in local Python
  virtualenv `.venv`).

## Usage

The repository is organized to be as self-contained as possible. Commands are
implemented in the project [Makefile](#makefile).

### Makefile

The `Makefile` is used for running commands, managing files, and maintaining
code quality. It includes a default `help` target that prints all make targets
and their descriptions grouped by function.

```shell
$ make
repo-template Makefile
Usage: make [COMMAND]

  help                      Print all Makefile targets (this message).
Tools
  license-headers           Update license headers.
Formatting
  format                    Format all files
  json-format               Format JSON files.
  md-format                 Format Markdown files.
  yaml-format               Format YAML files.
Linting
  lint                      Run all linters.
  actionlint                Runs the actionlint linter.
  zizmor                    Runs the zizmor linter.
  markdownlint              Runs the markdownlint linter.
  renovate-config-validator Validate Renovate configuration.
  textlint                  Runs the textlint linter.
  yamllint                  Runs the yamllint linter.
Maintenance
  clean                     Delete temporary files.
```

### Formatting and linting

Some `Makefile` targets for basic formatters and linters are included along
with GitHub Actions pre-submits. Where possible, pre-submits use `Makefile`
targets and those targets execute with the same settings as they do when run
locally. This is to give a consistent experience when attempting to reproduce
pre-submit errors.

Versioning of formatting, linting, and other tools are managed as tool
dependencies so they can be more easily maintained.

`Makefile` targets and linter/formatter configuration are designed to respect
`.gitignore` and not cross `git submodule` boundaries. However, you will need
to add files using `git add` for new files before they are picked up.

`Makefile` targets for linters will also produce human-readable output by
default, but will produce errors as [GitHub Actions workflow
commands](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions)
so they can be easily interpreted when run in Pull-Request [status
checks](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/about-status-checks).

### License headers

The `license-headers` make target will add license headers to files that are
missing it with the Copyright holder set to the current value of `git config
user.name`.

Files are checked for the existence license headers in status checks.

## Project documentation

This repository template includes stub documentation. Examples of
`CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, and `SECURITY.md` can be found in the
[`ianlewis/ianlewis`](https://github.com/ianlewis/ianlewis) repository and are
maintained in line with [GitHub recommended community
standards](https://opensource.guide/).

## Repository creation checklist

When creating a new repository from this template, the following checklist
is recommended to ensure the repository is set up correctly.

### Update configuration files

Files that should be updated include a TODO comment to indicate what changes
should made. You can run `make todos` to list all TODOs in the repository.

```shell
$ make todos
.github/workflows/pre-submit.units.yml:113:# TODO: Remove the next line for private repositories with GitHub Advanced Security.
.github/workflows/schedule.scorecard.yml:80:# TODO: Remove the next line for private repositories with GitHub Advanced Security.
CODEOWNERS:1:# TODO: Update CODEOWNERS
CODE_OF_CONDUCT.md:61:<!-- TODO: update Code of Conduct contact email -->
README.md:3:<!-- TODO: update badge urls -->
README.md:7:<!-- TODO: Update README contents. -->
```

### Recommended repository settings

The following repository settings are recommended in conjunction with this
repository template.

#### Rulesets

A `ruleset` should be created for the default branch with branch protection
rules that follow the [recommendations from OpenSSF
Scorecard](https://github.com/ossf/scorecard/blob/main/docs/checks.md#branch-protection)
as closely as possible.

##### Required Checks

The following checks should be marked as required:

- [ ] `actionlint`
- [ ] `formatting`
- [ ] `licence-headers`
- [ ] `markdownlint`
- [ ] `renovate-config-validator`
- [ ] `textlint`
- [ ] `fixme`
- [ ] `yamllint`
- [ ] `zizmor`

##### Require code scanning results

The following tools should be added to the required code scanning results.

- [ ] `CodeQL`
- [ ] `zizmor`

#### Advanced Security

1. [ ] **Private vulnerability reporting:**
       Enable [private vulnerability reporting] as mentioned in [`SECURITY.md`].
2. [ ] **Dependency Graph:**
       Enable the [dependency graph] and automatic dependency submission.
       Renovate relies on dependency graph for its [vulnerability
       alerts](https://docs.renovatebot.com/configuration-options/#vulnerabilityalerts)
       feature.
3. [ ] **Dependabot Alerts:**
       Enable [Dependabot alerts]. Renovate relies on Dependabot alerts for its
       [vulnerability
       alerts](https://docs.renovatebot.com/configuration-options/#vulnerabilityalerts)
       feature.

##### Code scanning

1. [ ] **CodeQL analysis:**
       Make sure "GitHub Actions (Public Preview)" is enabled in languages.
2. [ ] **Protection rules:**
    - [ ] **Security alert severity level:** Errors and warnings
    - [ ] **Standard alert severity level:** Errors and warnings
3. [ ] **Secret protection:**
       Get alerts when secrets are detected in the repository.
4. [ ] **Push protection:**
       Block pushing commits with secrets in them.

## Keeping repositories in sync

You can optionally keep repositories created with the template in sync with
changes to the template. Because repositories created from GitHub templates are
not forks, it is recommended to perform a squash merge to squash the merge as a
commit on your commit history.

```shell
# One time step: Add the repository template as a remote.
git remote add repo-template git@github.com:ianlewis/repo-template.git

# Fetch the latest version of the repo-template.
git fetch repo-template main

# Create a new squash merge commit.
git merge --no-edit --signoff --squash --allow-unrelated-histories repo-template/main
```

## Language-specific templates

A number of language specific templates based on this template are also available:

| Language              | Repository                                                                  |
| --------------------- | --------------------------------------------------------------------------- |
| Go                    | [`ianlewis/repo-template-go`](https://github.com/ianlewis/repo-template-go) |
| TypeScript/JavaScript | [`ianlewis/repo-template-ts`](https://github.com/ianlewis/repo-template-ts) |

## Contributing

PRs may be accepted to this template. See [`CONTRIBUTING.md`] for contributor
documentation.

[Dependabot alerts]: https://docs.github.com/en/code-security/dependabot/dependabot-alerts/about-dependabot-alerts
[dependency graph]: https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/about-the-dependency-graph
[private vulnerability reporting]: https://docs.github.com/en/code-security/security-advisories/working-with-repository-security-advisories/configuring-private-vulnerability-reporting-for-a-repository
[`CONTRIBUTING.md`]: ./CONTRIBUTING.md
[`SECURITY.md`]: ./SECURITY.md
[`Node.js`]: https://nodejs.org/
[`Python`]: https://www.python.org/
[`actionlint`]: https://github.com/rhysd/actionlint
[`mbrukman/autogen`]: https://github.com/mbrukman/autogen
[`git`]: https://git-scm.com/
[`jq`]: https://jqlang.org/
[`markdownlint`]: https://github.com/DavidAnson/markdownlint
[`prettier`]: https://prettier.io/
[`shellcheck`]: https://www.shellcheck.net/
[`textlint`]: https://textlint.github.io/
[`todos`]: https://github.com/ianlewis/todos
[`yamllint`]: https://www.yamllint.com/
[`zizmor`]: https://woodruffw.github.io/zizmor/
