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

# NOTE: the trixie-slim images are based on Debian 13 (Trixie).
FROM --platform=$BUILDPLATFORM node:24.13.0-trixie-slim@sha256:036dfa7e82a1e867b09248440a2b6635b3f8de557f69e60bac923a10c6e696a8
ARG TARGETOS
ARG TARGETARCH
ARG TARGETPLATFORM
ARG BUILDPLATFORM

ENV PATH=/usr/local/go/bin:$PATH

# renovate: datasource=golang-version depName=golang versioning=loose
ENV GOLANG_VERSION=1.25.7
ENV GOLANG_DIGEST_VAR_NAME=GOLANG_DIGEST_${TARGETOS}_${TARGETARCH}
ENV GOLANG_DIGEST_linux_amd64=12e6d6a191091ae27dc31f6efc630e3a3b8ba409baf3573d955b196fdf086005
ENV GOLANG_DIGEST_linux_arm64=ba611a53534135a81067240eff9508cd7e256c560edd5d8c2fef54f083c07129
# renovate: datasource=go depName=golang.org/x/tools/gopls versioning=loose
ENV GOPLS_VERSION=0.19.1

# Package versions
# renovate: suite=trixie depName=curl
ENV CURL_VERSION=8.14.1-2+deb13u2
# renovate: suite=trixie depName=gcc
ENV GCC_VERSION=4:14.2.0-1
# renovate: suite=trixie depName=gosu
ENV GOSU_VERSION=1.17-3+b4
# renovate: suite=trixie depName=git
ENV GIT_VERSION=1:2.47.3-0+deb13u1
# renovate: suite=trixie depName=libc6-dev
ENV LIBC6_DEV_VERSION=2.41-12+deb13u1
# renovate: suite=trixie depName=make
ENV MAKE_VERSION=4.4.1-2
# renovate: suite=trixie depName=python3
ENV PYTHON3_VERSION=3.13.5-1
# renovate: suite=trixie depName=python3-pip
ENV PYTHON3_PIP_VERSION=25.1.1+dfsg-1
# renovate: suite=trixie depName=wget
ENV WGET_VERSION=1.25.0-2
# renovate: suite=trixie depName=zip
ENV ZIP_VERSION=3.0-15
# renovate: suite=trixie depName=unzip
ENV UNZIP_VERSION=6.0-29

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Install dependencies
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    curl=${CURL_VERSION} \
    g++=${GCC_VERSION} \
    gcc=${GCC_VERSION} \
    gosu=${GOSU_VERSION} \
    git=${GIT_VERSION} \
    libc6-dev=${LIBC6_DEV_VERSION} \
    make=${MAKE_VERSION} \
    python3=${PYTHON3_VERSION} \
    python3-venv=${PYTHON3_VERSION} \
    python3-pip=${PYTHON3_PIP_VERSION} \
    wget=${WGET_VERSION} \
    zip=${ZIP_VERSION} \
    unzip=${UNZIP_VERSION} \
    && rm -rf /var/lib/apt/lists/*

RUN url="https://dl.google.com/go/go${GOLANG_VERSION}.${TARGETOS}-${TARGETARCH}.tar.gz"; \
    sha256="${!GOLANG_DIGEST_VAR_NAME}"; \
	wget --progress=dot:giga -O go.tgz.asc "${url}.asc"; \
	wget --progress=dot:giga -O go.tgz "${url}" --progress=dot:giga; \
	echo "${sha256} *go.tgz" | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
    # smoke test \
    go version; \
    # install gopls \
    go install "golang.org/x/tools/gopls@v${GOPLS_VERSION}";

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
