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
FROM node:24.6.0-slim@sha256:2664422177c5319330770fc78532a87050cff031a4f60b0f8449d1b80bf7488b

ENV PATH=/usr/local/go/bin:$PATH

# Package versions
# renovate: suite=trixie depName=curl
ENV CURL_VERSION=8.14.1-2
# renovate: suite=trixie depName=g++
ENV GPP_VERSION=4:14.2.0-1
# renovate: suite=trixie depName=gcc
ENV GCC_VERSION=4:14.2.0-1
# renovate: suite=trixie depName=gosu
ENV GOSU_VERSION=1.17-3+b4
# renovate: suite=trixie depName=git
ENV GIT_VERSION=1:2.47.2-0.2
# renovate: suite=trixie depName=libc6-dev
ENV LIBC6_DEV_VERSION=2.41-12
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
    g++=${GPP_VERSION} \
    gcc=${GCC_VERSION} \
    gosu=${GOSU_VERSION} \
    git=${GIT_VERSION} \
    libc6-dev=${LIBC6_DEV_VERSION} \
    make=${MAKE_VERSION} \
    python3=${PYTHON3_VERSION} \
    python3-pip=${PYTHON3_PIP_VERSION} \
    wget=${WGET_VERSION} \
    zip=${ZIP_VERSION} \
    unzip=${UNZIP_VERSION} \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

WORKDIR /workspace
ENTRYPOINT ["/entrypoint.sh"]
