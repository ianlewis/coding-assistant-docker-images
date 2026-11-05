# Copyright 2026 Ian Lewis
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

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

SHELL := bash
.SHELLFLAGS = -ueo pipefail -c

DEBUG_LOGGING ?=
GITHUB_ACTIONS ?=
RUNNER_DEBUG ?=
ACTIONS_RUNNER_DEBUG ?=
ACTIONS_STEP_DEBUG ?=

ifeq ($(DEBUG_LOGGING),)
  ifeq ($(GITHUB_ACTIONS),true)
    ifneq ($(RUNNER_DEBUG),)
      DEBUG_LOGGING := true
    else ifeq ($(ACTIONS_RUNNER_DEBUG),true)
      DEBUG_LOGGING := true
    else ifeq ($(ACTIONS_STEP_DEBUG),true)
      DEBUG_LOGGING := true
    endif
  endif
endif

ifeq ($(DEBUG_LOGGING),true)
  .SHELLFLAGS := -x $(.SHELLFLAGS)
endif

.ONESHELL:
.DELETE_ON_ERROR:

uname_s := $(shell uname -s)
uname_m := $(shell uname -m)
arch.x86_64 := amd64
arch.aarch64 := arm64
arch.arm64 := arm64
arch := $(arch.$(uname_m))
kernel.Linux := linux
kernel.Darwin := darwin
kernel := $(kernel.$(uname_s))

OUTPUT_FORMAT ?= $(shell if [ "$(GITHUB_ACTIONS)" == "true" ]; then echo "github"; else echo ""; fi)
REPO_ROOT := $(shell git rev-parse --show-toplevel 2>/dev/null)
REPO_NAME := $(shell basename "$(REPO_ROOT)")

# renovate: datasource=github-releases depName=aquaproj/aqua versioning=loose
AQUA_VERSION ?= v2.55.3
AQUA_REPO := github.com/aquaproj/aqua
AQUA_CHECKSUM.linux.amd64 := 326c9119aef16b42e41a5d2af9d62ee82ed78abbb6651de515d51b0edcd613d9
AQUA_CHECKSUM.linux.arm64 := 772d9f08c60ad888586bfc5532fe41a0532c276d8723e2bf8fccb139ccf8f8cf
AQUA_CHECKSUM.darwin.arm64 := 7e602e41c7f7a5c6b1504f6a06fbb7bca13f2b0604067c55f79b99b310c76f68
AQUA_CHECKSUM ?= $(AQUA_CHECKSUM.$(kernel).$(arch))
AQUA_URL := https://$(AQUA_REPO)/releases/download/$(AQUA_VERSION)/aqua_$(kernel)_$(arch).tar.gz
export AQUA_ROOT_DIR = $(REPO_ROOT)/.aqua

export PATH := $(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION):$(AQUA_ROOT_DIR)/bin:$(PATH)

GREP := $(shell command -v ggrep 2>/dev/null || command -v grep 2>/dev/null)
AWK := $(shell command -v gawk 2>/dev/null || command -v awk 2>/dev/null)
MKTEMP := $(shell command -v gmktemp 2>/dev/null || command -v mktemp 2>/dev/null)

.PHONY: help
help: ## Print all Makefile targets (this message).
	@echo "$(REPO_NAME) Makefile"
	echo "Usage: $(MAKE) [COMMAND]"
	echo ""
	normal=""
	cyan=""
	if command -v tput >/dev/null 2>&1; then
		if [ -t 1 ]; then
			normal=$$(tput sgr0)
			cyan=$$(tput setaf 6)
		fi
	fi
	$(GREP) --no-filename -E '^([/a-z.A-Z0-9_%-]+:.*?|)##' $(MAKEFILE_LIST) | \
		$(AWK) \
			--assign=normal="$${normal}" \
			--assign=cyan="$${cyan}" \
			'BEGIN {FS = "(:.*?|)## ?"}; {
				if (length($$1) > 0) {
					printf("  " cyan "%-25s" normal " %s\n", $$1, $$2)
				} else {
					if (length($$2) > 0) {
						printf("%s\n", $$2)
					}
				}
			}'

$(REPO_ROOT)/package-lock.json: $(REPO_ROOT)/package.json $(AQUA_ROOT_DIR)/.installed
	@echo "Updating Node.js dependencies..."
	loglevel="notice"
	if [ -n "$(DEBUG_LOGGING)" ]; then
		loglevel="verbose"
	fi
	nointegrity=""
	noresolved=""
	if [ -f "$@" ]; then
		nointegrity=$$(jq '.packages | del(."") | .[] | select(has("integrity") | not)' < $@)
		noresolved=$$(jq '.packages | del(."") | .[] | select(has("resolved") | not)' < $@)
	fi
	if [ ! -f "$@" ] || [ -n "$${nointegrity}" ] || [ -n "$${noresolved}" ]; then
		rm -f $@
		npm --loglevel="$${loglevel}" install \
			--no-audit \
			--no-fund
	else
		npm --loglevel="$${loglevel}" install \
			--package-lock-only \
			--no-audit \
			--no-fund
	fi

$(REPO_ROOT)/node_modules/.installed: $(REPO_ROOT)/package-lock.json
	@echo "Installing Node.js dependencies..."
	loglevel="notice"
	if [ -n "$(DEBUG_LOGGING)" ]; then
		loglevel="verbose"
	fi
	npm --loglevel="$${loglevel}" clean-install
	npm --loglevel="$${loglevel}" audit signatures
	touch $@

$(REPO_ROOT)/.venv/bin/activate:
	@echo "Creating Python virtual environment..."
	python -m venv $(REPO_ROOT)/.venv

$(REPO_ROOT)/.venv/.installed: $(REPO_ROOT)/requirements-dev.txt $(REPO_ROOT)/.venv/bin/activate
	@echo "Installing Python dependencies..."
	$(REPO_ROOT)/.venv/bin/pip install -r $< --require-hashes
	touch $@

$(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION)/aqua:
	@echo "Installing aqua $(AQUA_VERSION)..."
	mkdir -p $(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION)
	tempfile=$$($(MKTEMP) --suffix=".aqua-$(AQUA_VERSION).tar.gz")
	curl -sSLo "$${tempfile}" "$(AQUA_URL)"
	echo "$(AQUA_CHECKSUM)  $${tempfile}" | shasum -a 256 -c
	tar -x -C $(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION) -f "$${tempfile}"

$(AQUA_ROOT_DIR)/.installed: $(REPO_ROOT)/.aqua.yaml $(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION)/aqua
	@echo "Installing Aqua tools..."
	loglevel="info"
	if [ -n "$(DEBUG_LOGGING)" ]; then
		loglevel="debug"
	fi
	$(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION)/aqua \
		--config "$(REPO_ROOT)/.aqua.yaml" \
		--log-level "$${loglevel}" \
		install
	touch $@
