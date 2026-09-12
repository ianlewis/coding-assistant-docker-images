# Copyright 2025 Ian Lewis
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

FROM ghcr.io/ianlewis/coding-assistant-docker-images-base:latest@sha256:eb5cb4aa74daac7cb4ad24d4bf0dd62d0de2965d64c6f814e03e81b268365713
ARG TARGETARCH
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# renovate: datasource=github-releases depName=google-antigravity/antigravity-cli versioning=loose
ARG ANTIGRAVITY_CLI_VERSION=1.2.2

WORKDIR /app

COPY config.sh /config.sh

# If target arch is amd64 set ARCH to x64, else set it to arm64
RUN if [ "${TARGETARCH}" = "amd64" ]; then \
        export ARCH="x64"; \
    else \
        export ARCH="${TARGETARCH}"; \
    fi && \
    curl -sSLo agy_cli_linux.tar.gz https://github.com/google-antigravity/antigravity-cli/releases/download/${ANTIGRAVITY_CLI_VERSION}/agy_cli_linux_${ARCH}.tar.gz && \
    tar -xzf agy_cli_linux.tar.gz && \
    rm agy_cli_linux.tar.gz && \
    chmod +x antigravity && \
    mv antigravity /usr/local/bin/agy && \
    agy --version

WORKDIR /workspace
CMD ["agy"]
