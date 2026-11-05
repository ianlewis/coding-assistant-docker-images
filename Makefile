# Copyright 2024 Ian Lewis
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include include.mk

BASE_IMAGE_NAME ?= ghcr.io/ianlewis/base
ANTIGRAVITY_IMAGE_NAME ?= ghcr.io/ianlewis/antigravity
CLAUDECODE_IMAGE_NAME ?= ghcr.io/ianlewis/claude-code
CODEX_IMAGE_NAME ?= ghcr.io/ianlewis/codex
COPILOT_IMAGE_NAME ?= ghcr.io/ianlewis/copilot
OPENCODE_IMAGE_NAME ?= ghcr.io/ianlewis/opencode

XDG_BIN ?= $(HOME)/.local/bin
XDG_CONFIG_HOME ?= $(HOME)/.config
XDG_DATA_HOME ?= $(HOME)/.local/share

## Build
#####################################################################

.PHONY: all
all: test base antigravity-docker claude-code-docker codex-docker copilot-docker opencode-docker ## Build everything.

## Testing
#####################################################################

.PHONY: test
test: lint ## Run all tests.

## Installation
#####################################################################

.PHONY: install
install: ## Install agent launcher scripts.
	@cp -f \
		$(REPO_ROOT)/config/policy.cue \
		$(XDG_CONFIG_HOME)/coding-assistant-docker-images/
	cp -f \
		$(REPO_ROOT)/bin/agy.bash \
		$(XDG_BIN)/agy
	cp -f \
		$(REPO_ROOT)/bin/claude.bash \
		$(XDG_BIN)/claude
	cp -f \
		$(REPO_ROOT)/bin/codex.bash \
		$(XDG_BIN)/codex
	cp -f \
		$(REPO_ROOT)/bin/copilot.bash \
		$(XDG_BIN)/copilot
	cp -f \
		$(REPO_ROOT)/bin/opencode.bash \
		$(XDG_BIN)/opencode
	chmod +x \
		$(XDG_BIN)/agy \
		$(XDG_BIN)/claude \
		$(XDG_BIN)/codex \
		$(XDG_BIN)/copilot \
		$(XDG_BIN)/opencode

## Agents
#####################################################################

run-antigravity: antigravity-docker ## Build and run Claude Code from source.
	@mkdir -p "$(XDG_DATA_HOME)/antigravity-docker"
	docker run \
		--rm \
		--interactive \
		--tty \
        --runtime io.containerd.runsc.v1 \
		--volume "$(REPO_ROOT):/workspace" \
		--volume "$(XDG_DATA_HOME)/antigravity-docker:/gemini" \
		"$(ANTIGRAVITY_IMAGE_NAME)"

run-claude-code: claude-code-docker ## Build and run Claude Code from source.
	@mkdir -p "$(XDG_DATA_HOME)/claude-code-docker"
	if [ ! -f "$(XDG_DATA_HOME)/claude-code-docker/claude.json" ]; then \
		echo "{}" > "$(XDG_DATA_HOME)/claude-code-docker/claude.json"
	fi
	docker run \
		--rm \
		--interactive \
		--tty \
        --runtime io.containerd.runsc.v1 \
		--volume "$(REPO_ROOT):/workspace" \
		--volume "$(XDG_DATA_HOME)/claude-code-docker/claude.json:/claude.json" \
		--volume "$(XDG_DATA_HOME)/claude-code-docker:/claude" \
		"$(CLAUDECODE_IMAGE_NAME)"

run-codex: codex-docker ## Build and run codex from source.
	@mkdir -p "$(XDG_DATA_HOME)/codex-docker"
	docker run \
		--rm \
		--interactive \
		--tty \
        --runtime io.containerd.runsc.v1 \
		--volume "$(REPO_ROOT):/workspace" \
		--volume "$(XDG_DATA_HOME)/codex-docker:/codex" \
		"$(CODEX_IMAGE_NAME)" codex \
    		--config "shell_environment_policy.include_only='[\"PATH\",\"HOME\"]'"

run-copilot: copilot-docker ## Build and run copilot from source.
	@mkdir -p "$(XDG_DATA_HOME)/copilot-docker"
	docker run \
		--rm \
		--interactive \
		--tty \
        --runtime io.containerd.runsc.v1 \
		--volume "$(REPO_ROOT):/workspace" \
		--volume "$(XDG_DATA_HOME)/copilot-docker:/copilot" \
		"$(COPILOT_IMAGE_NAME)"

run-opencode: opencode-docker ## Build and run opencode from source.
	@mkdir -p "$(XDG_DATA_HOME)/opencode-docker/share"
	mkdir -p "$(XDG_DATA_HOME)/opencode-docker/state"
	mkdir -p "$(XDG_DATA_HOME)/opencode-docker/config"
	docker run \
		--rm \
		--interactive \
		--tty \
        --runtime io.containerd.runsc.v1 \
		--volume "$(REPO_ROOT):/workspace" \
		--volume "$(XDG_DATA_HOME)/opencode-docker/share:/opencode/share" \
		--volume "$(XDG_DATA_HOME)/opencode-docker/state:/opencode/state" \
		--volume "$(XDG_DATA_HOME)/opencode-docker/config:/opencode/config" \
		"$(OPENCODE_IMAGE_NAME)" opencode --help

## Image
#####################################################################

.PHONY: base
base: base/Dockerfile base/entrypoint.sh ## Build the opencode Docker image.
	@extra_args=()
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		extra_args=("--progress=plain")
	fi
	docker buildx build \
		--output type=docker \
		--secret id=gh_token,env=GH_TOKEN \
		--tag "$(BASE_IMAGE_NAME)" \
		--file base/Dockerfile \
		"$${extra_args[@]}" \
		base/

.PHONY: antigravity-docker
antigravity-docker: antigravity/Dockerfile antigravity/config.sh ## Build the antigravity-cli Docker image.
	@if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		docker buildx build \
			--output type=docker \
			--progress=plain \
			--tag "$(ANTIGRAVITY_IMAGE_NAME)" \
			--file antigravity/Dockerfile \
			antigravity/
	else \
		docker buildx build \
			--output type=docker \
			--tag "$(ANTIGRAVITY_IMAGE_NAME)" \
			--file antigravity/Dockerfile \
			antigravity/
	fi

claude-code/package-lock.json: claude-code/package.json
	@npm install \
		--prefix claude-code/ \
		--package-lock-only \
		--no-audit \
		--no-fund \
		claude-code/

.PHONY: claude-code-docker
claude-code-docker: claude-code/Dockerfile claude-code/package-lock.json claude-code/config.sh ## Build the claude-code Docker image.
	@if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		docker buildx build \
			--output type=docker \
			--progress=plain \
			--tag "$(CLAUDECODE_IMAGE_NAME)" \
			--file claude-code/Dockerfile \
			claude-code/
	else \
		docker buildx build \
			--output type=docker \
			--tag "$(CLAUDECODE_IMAGE_NAME)" \
			--file claude-code/Dockerfile \
			claude-code/
	fi

codex/package-lock.json: codex/package.json
	@npm install \
		--prefix codex/ \
		--package-lock-only \
		--no-audit \
		--no-fund \
		codex/

.PHONY: codex-docker
codex-docker: codex/Dockerfile codex/package-lock.json codex/config.sh ## Build the codex Docker image.
	@if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		docker buildx build \
			--output type=docker \
			--progress=plain \
			--tag "$(CODEX_IMAGE_NAME)" \
			--file codex/Dockerfile \
			codex/
	else \
		docker buildx build \
			--output type=docker \
			--tag "$(CODEX_IMAGE_NAME)" \
			--file codex/Dockerfile \
			codex/
	fi

copilot/package-lock.json: copilot/package.json
	@npm install \
		--prefix copilot/ \
		--package-lock-only \
		--no-audit \
		--no-fund \
		copilot/

.PHONY: copilot-docker
copilot-docker: copilot/Dockerfile copilot/package-lock.json copilot/config.sh ## Build the copilot Docker image.
	@if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		docker buildx build \
			--output type=docker \
			--progress=plain \
			--tag "$(COPILOT_IMAGE_NAME)" \
			--file copilot/Dockerfile \
			copilot/
	else \
		docker buildx build \
			--output type=docker \
			--tag "$(COPILOT_IMAGE_NAME)" \
			--file copilot/Dockerfile \
			copilot/
	fi

opencode/package-lock.json: opencode/package.json
	@npm install \
		--prefix opencode/ \
		--package-lock-only \
		--no-audit \
		--no-fund \
		opencode/

.PHONY: opencode-docker
opencode-docker: opencode/Dockerfile opencode/package-lock.json opencode/config.sh ## Build the opencode Docker image.
	@if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		docker buildx build \
			--output type=docker \
			--progress=plain \
			--tag "$(OPENCODE_IMAGE_NAME)" \
			--file opencode/Dockerfile \
			opencode/
	else \
		docker buildx build \
			--output type=docker \
			--tag "$(OPENCODE_IMAGE_NAME)" \
			--file opencode/Dockerfile \
			opencode/
	fi


## Formatting
#####################################################################

.PHONY: format
format: json-format license-headers md-format yaml-format ## Format all files

.PHONY: json-format
json-format: $(REPO_ROOT)/node_modules/.installed ## Format JSON files.
	@loglevel="log"
	if [ -n "$(DEBUG_LOGGING)" ]; then \
		loglevel="debug"
	fi
	files=$$( \
		git ls-files --deduplicate \
			'*.json' \
			'*.json5' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	)
	if [ "$${files}" == "" ]; then \
		exit 0
	fi
	$(REPO_ROOT)/node_modules/.bin/prettier \
		--log-level "$${loglevel}" \
		--no-error-on-unmatched-pattern \
		--write \
		$${files}

.PHONY: license-headers
license-headers: ## Update license headers.
	@files=$$( \
		git ls-files --deduplicate \
			'*.c' \
			'*.cpp' \
			'*.go' \
			'*.h' \
			'*.hpp' \
			'*.js' \
			'*.lua' \
			'*.py' \
			'*.rb' \
			'*.rs' \
			'*.yaml' \
			'*.yml' \
			'Makefile' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	)
	name=$$(git config user.name)
	if [ "$${name}" == "" ]; then \
		>&2 echo "git user.name is required."
		>&2 echo "Set it up using:"
		>&2 echo "git config user.name \"John Doe\""
		exit 1
	fi
	for filename in $${files}; do \
		if ! ( head "$${filename}" | $(GREP) -iL "Copyright" > /dev/null ); then \
			$(REPO_ROOT)/third_party/mbrukman/autogen/autogen.sh \
				--in-place \
				--no-code \
				--no-tlc \
				--copyright "$${name}" \
				--license apache \
				"$${filename}"
		fi
	done


.PHONY: md-format
md-format: $(REPO_ROOT)/node_modules/.installed ## Format Markdown files.
	@loglevel="log"
	if [ -n "$(DEBUG_LOGGING)" ]; then \
		loglevel="debug"
	fi
	files=$$( \
		git ls-files --deduplicate \
			'*.md' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	)
	if [ "$${files}" == "" ]; then \
		exit 0
	fi
	# NOTE: prettier uses .editorconfig for tab-width. \
	$(REPO_ROOT)/node_modules/.bin/prettier \
		--log-level "$${loglevel}" \
		--no-error-on-unmatched-pattern \
		--write \
		$${files}

.PHONY: yaml-format
yaml-format: $(REPO_ROOT)/node_modules/.installed ## Format YAML files.
	@loglevel="log"
	if [ -n "$(DEBUG_LOGGING)" ]; then \
		loglevel="debug"
	fi
	files=$$( \
		git ls-files --deduplicate \
			'*.yml' \
			'*.yaml' \
	)
	if [ "$${files}" == "" ]; then \
		exit 0
	fi
	$(REPO_ROOT)/node_modules/.bin/prettier \
		--log-level "$${loglevel}" \
		--no-error-on-unmatched-pattern \
		--write \
		$${files}

## Linting
#####################################################################

.PHONY: lint
lint: actionlint checkmake commitlint fixme format-check hadolint markdownlint renovate-config-validator shellcheck textlint yamllint zizmor ## Run all linters.

.PHONY: actionlint
actionlint: $(AQUA_ROOT_DIR)/.installed ## Runs the actionlint linter.
	@# NOTE: We need to ignore config files used in tests. \
	files=$$( \
		git ls-files --deduplicate \
			'.github/workflows/*.yml' \
			'.github/workflows/*.yaml' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	)
	if [ "$${files}" == "" ]; then \
		exit 0
	fi
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		actionlint \
			-format '{{range $$err := .}}::error file={{$$err.Filepath}},line={{$$err.Line}},col={{$$err.Column}}::{{$$err.Message}}%0A```%0A{{replace $$err.Snippet "\\n" "%0A"}}%0A```\n{{end}}' \
			-ignore 'SC2016:' \
			$${files}
	else \
		actionlint \
			-ignore 'SC2016:' \
			$${files}
	fi

.PHONY: checkmake
checkmake: $(AQUA_ROOT_DIR)/.installed ## Runs the checkmake linter.
	@# NOTE: We need to ignore config files used in tests. \
	files=$$( \
		git ls-files --deduplicate \
			'Makefile' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	)
	if [ "$${files}" == "" ]; then \
		exit 0
	fi
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		# TODO: Remove newline from the format string after updating checkmake. \
		checkmake \
			--format '::error file={{.FileName}},line={{.LineNumber}}::{{.Rule}}: {{.Violation}}'$$'\n' \
			$${files}
	else \
		checkmake $${files}
	fi

.PHONY: commitlint
COMMITLINT_FROM_REF ?=
COMMITLINT_TO_REF ?=
commitlint: $(REPO_ROOT)/node_modules/.installed ## Run commitlint linter.
	@commitlint_from=$(COMMITLINT_FROM_REF)
	commitlint_to=$(COMMITLINT_TO_REF)
	if [ "$${commitlint_from}" == "" ]; then \
		# Try to get the default branch without hitting the remote server \
		if git symbolic-ref --short refs/remotes/origin/HEAD >/dev/null 2>&1; then \
			commitlint_from=$$(git symbolic-ref --short refs/remotes/origin/HEAD)
		elif git show-ref refs/remotes/origin/master >/dev/null 2>&1; then \
			commitlint_from="origin/master"
		else \
			commitlint_from="origin/main"
		fi
	fi
	if [ "$${commitlint_to}" == "" ]; then \
		# if head is on the commitlint_from branch, then we will lint the \
		# last commit by default. \
		current_branch=$$(git rev-parse --abbrev-ref HEAD)
		if [ "$${commitlint_from}" == "$${current_branch}" ]; then \
			commitlint_from="HEAD~1"
		fi
		commitlint_to="HEAD"
	fi
	$(REPO_ROOT)/node_modules/.bin/commitlint \
		--from "$${commitlint_from}" \
		--to "$${commitlint_to}" \
		--verbose \
		--strict

.PHONY: fixme
fixme: $(AQUA_ROOT_DIR)/.installed ## Check for outstanding FIXMEs.
	@output="default"
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		output="github"
	fi
	# NOTE: todos does not use `git ls-files` because many files might be \
	# 		unsupported and generate an error if passed directly on the \
	# 		command line. \
	todos \
		--output "$${output}" \
		--todo-types="FIXME,Fixme,fixme,BUG,Bug,bug,XXX,COMBAK"

.PHONY: format-check
format-check: ## Check that files are properly formatted.
	@if [ -n "$$(git diff)" ]; then \
		>&2 echo "The working directory is dirty. Please commit, stage, or stash changes and try again."
		exit 1
	fi
	$(MAKE) format
	exit_code=0
	if [ -n "$$(git diff)" ]; then \
		>&2 echo "Some files need to be formatted. Please run 'make format' and try again."
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			echo "::group::git diff"
		fi
		git --no-pager diff
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			echo "::endgroup::"
		fi
		exit_code=1
	fi
	git restore .
	exit "$${exit_code}"

.PHONY: hadolint
hadolint: $(AQUA_ROOT_DIR)/.installed ## Runs the hadolint linter.
	@files=$$( \
		git ls-files --deduplicate \
			'[Dd]ockerfile' \
			'*/[Dd]ockerfile' \
			'*.dockerfile' \
			'[Cc]ontainerfile' \
			'*/[Cc]ontainerfile' \
			'*.containerfile' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	)
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		hadolint -f checkstyle $${files}
	else \
		hadolint $${files}
	fi

.PHONY: markdownlint
markdownlint: $(REPO_ROOT)/node_modules/.installed $(AQUA_ROOT_DIR)/.installed ## Runs the markdownlint linter.
	@# NOTE: Issue and PR templates are handled specially so we can disable \
	# MD041/first-line-heading/first-line-h1 without adding an ugly html comment \
	# at the top of the file. \
	files=$$( \
		git ls-files --deduplicate \
			'*.md' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	)
	if [ "$${files}" == "" ]; then \
		exit 0
	fi
	$(REPO_ROOT)/node_modules/.bin/markdownlint-cli2 $${files}

.PHONY: renovate-config-validator
renovate-config-validator: $(REPO_ROOT)/node_modules/.installed ## Validate Renovate configuration.
	@$(REPO_ROOT)/node_modules/.bin/renovate-config-validator \
		--strict

.PHONY: shellcheck
SHELLCHECK_ARGS ?=
shellcheck: $(AQUA_ROOT_DIR)/.installed ## Runs the shellcheck linter.
	@files=$$( \
		git ls-files --deduplicate \
			| xargs file \
			| $(GREP) -e ':.*shell' \
			| cut -d':' -f1 \
	)
	if [ "$${files}" == "" ]; then \
		exit 0
	fi
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		exit_code=0
		while IFS="" read -r p && [ -n "$$p" ]; do \
			level=$$(echo "$$p" | jq -c '.level // empty' | tr -d '"')
			file=$$(echo "$$p" | jq -c '.file // empty' | tr -d '"')
			line=$$(echo "$$p" | jq -c '.line // empty' | tr -d '"')
			endline=$$(echo "$$p" | jq -c '.endLine // empty' | tr -d '"')
			col=$$(echo "$$p" | jq -c '.column // empty' | tr -d '"')
			endcol=$$(echo "$$p" | jq -c '.endColumn // empty' | tr -d '"')
			message=$$(echo "$$p" | jq -c '.message // empty' | tr -d '"')
			exit_code=1
			case $$level in \
			"info") \
				echo "::notice file=$${file},line=$${line},endLine=$${endline},col=$${col},endColumn=$${endcol}::$${message}"
				;;
			"warning") \
				echo "::warning file=$${file},line=$${line},endLine=$${endline},col=$${col},endColumn=$${endcol}::$${message}"
				;;
			"error") \
				echo "::error file=$${file},line=$${line},endLine=$${endline},col=$${col},endColumn=$${endcol}::$${message}"
				;;
			esac
		done <<< "$$(echo -n "$$files" | xargs shellcheck -f json $(SHELLCHECK_ARGS) | jq -c '.[]')"
		exit "$${exit_code}"
	else \
		echo -n "$$files" | xargs shellcheck $(SHELLCHECK_ARGS)
	fi

.PHONY: textlint
textlint: $(REPO_ROOT)/node_modules/.installed $(AQUA_ROOT_DIR)/.installed ## Runs the textlint linter.
	@files=$$( \
		git ls-files --deduplicate \
			'*.md' \
			'*.txt' \
			':!:requirements*.txt' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	)
	if [ "$${files}" == "" ]; then \
		exit 0
	fi
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		exit_code=0
		while IFS="" read -r p && [ -n "$$p" ]; do \
			filePath=$$(echo "$$p" | jq -cr '.filePath // empty')
			file=$$(realpath --relative-to="." "$${filePath}")
			while IFS="" read -r m && [ -n "$$m" ]; do \
				line=$$(echo "$$m" | jq -cr '.loc.start.line // empty')
				endline=$$(echo "$$m" | jq -cr '.loc.end.line // empty')
				col=$$(echo "$${m}" | jq -cr '.loc.start.column // empty')
				endcol=$$(echo "$${m}" | jq -cr '.loc.end.column // empty')
				message=$$(echo "$$m" | jq -cr '.message // empty')
				exit_code=1
				echo "::error file=$${file},line=$${line},endLine=$${endline},col=$${col},endColumn=$${endcol}::$${message}"
			done <<<"$$(echo "$$p" | jq -cr '.messages[] // empty')"
		done <<< "$$($(REPO_ROOT)/node_modules/.bin/textlint -c .textlintrc.yaml --format json $${files} 2>&1 | jq -c '.[]')"
		exit "$${exit_code}"
	else \
		$(REPO_ROOT)/node_modules/.bin/textlint \
			$${files}
	fi

.PHONY: yamllint
yamllint: $(REPO_ROOT)/.venv/.installed ## Runs the yamllint linter.
	@files=$$( \
		git ls-files --deduplicate \
			'*.yml' \
			'*.yaml' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	)
	if [ "$${files}" == "" ]; then \
		exit 0
	fi
	format="standard"
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		format="github"
	fi
	$(REPO_ROOT)/.venv/bin/yamllint \
		--strict \
		--format "$${format}" \
		$${files}

.PHONY: zizmor
zizmor: $(REPO_ROOT)/.venv/.installed ## Runs the zizmor linter.
	@# NOTE: On GitHub actions this outputs SARIF format to zizmor.sarif.json \
	#       in addition to outputting errors to the terminal. \
	files=$$( \
		git ls-files --deduplicate \
			'.github/workflows/*.yml' \
			'.github/workflows/*.yaml' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	)
	if [ "$${files}" == "" ]; then \
		exit 0
	fi
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		$(REPO_ROOT)/.venv/bin/zizmor \
			--config .zizmor.yml \
			--quiet \
			--pedantic \
			--format sarif \
			$${files} > zizmor.sarif.json
	fi
	$(REPO_ROOT)/.venv/bin/zizmor \
		--config .zizmor.yml \
		--quiet \
		--pedantic \
		--format plain \
		$${files}

## Maintenance
#####################################################################

.PHONY: update-lockfiles
update-lockfiles: $(AQUA_ROOT_DIR)/.installed $(REPO_ROOT)/package-lock.json ## Update lockfiles.
	@$(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION)/aqua \
		--config "$(REPO_ROOT)/.aqua.yaml" \
		update-checksum \
		--prune

.PHONY: todos
todos: $(AQUA_ROOT_DIR)/.installed ## Print outstanding TODOs.
	@output="default"
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
		output="github"
	fi
	# NOTE: todos does not use `git ls-files` because many files might be \
	# 		unsupported and generate an error if passed directly on the \
	# 		command line. \
	todos \
		--output "$${output}" \
		--todo-types="TODO,Todo,todo,FIXME,Fixme,fixme,BUG,Bug,bug,XXX,COMBAK"

.PHONY: clean
clean: ## Delete temporary files.
	@$(RM) -r .bin
	@$(RM) -r $(AQUA_ROOT_DIR)
	@$(RM) -r .venv
	@$(RM) -r node_modules
	@$(RM) *.sarif.json
