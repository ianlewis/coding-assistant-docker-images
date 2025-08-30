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

# NOTE: the 22.17.0-slim image is based on Debian 12 (Bookworm).
FROM node:22.18.0-slim@sha256:85a080b95b99079d3a07662fdd4be5b966603460205865f8f7a447955b3ea35c

ENV PATH=/usr/local/go/bin:$PATH

# renovate: datasource=golang-version depName=golang versioning=loose
ENV GOLANG_VERSION=1.24.4
# renovate: datasource=go depName=golang.org/x/tools/gopls versioning=loose
ENV GOPLS_VERSION=0.19.1

# Package versions
# renovate: datasource=repology depName=debian_12/curl versioning=loose
ENV CURL_VERSION=7.88.1-10+deb12u12
# renovate: datasource=repology depName=debian_12/g++ versioning=loose
ENV GPP_VERSION=4:12.2.0-3
# renovate: datasource=repology depName=debian_12/gcc versioning=loose
ENV GCC_VERSION=4:12.2.0-3
# renovate: datasource=repology depName=debian_12/gosu versioning=loose
ENV GOSU_VERSION=1.14-1+b10
# renovate: datasource=repology depName=debian_12/git versioning=loose
ENV GIT_VERSION=1:2.39.5-0+deb12u2
# renovate: datasource=repology depName=debian_12/glibc versioning=loose
ENV LIBC6_DEV_VERSION=2.36-9+deb12u10
# renovate: datasource=repology depName=debian_12/make-dfsg versioning=loose
ENV MAKE_VERSION=4.3-4.1
# renovate: datasource=repology depName=debian_12/python3 versioning=loose
ENV PYTHON3_VERSION=3.11.2-1+b1
# renovate: datasource=repology depName=debian_12/python3 versioning=loose
ENV PYTHON3_VENV_VERSION=3.11.2-1+b1
# renovate: datasource=repology depName=debian_12/python3-pip versioning=loose
ENV PYTHON3_PIP_VERSION=23.0.1+dfsg-1
# renovate: datasource=repology depName=debian_12/wget versioning=loose
ENV WGET_VERSION=1.21.3-1+deb12u1
# renovate: datasource=repology depName=debian_12/zip versioning=loose
ENV ZIP_VERSION=3.0-13
# renovate: datasource=repology depName=debian_12/unzip versioning=loose
ENV UNZIP_VERSION=6.0-28

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
    python3-venv=${PYTHON3_VENV_VERSION} \
    wget=${WGET_VERSION} \
    zip=${ZIP_VERSION} \
    unzip=${UNZIP_VERSION} \
    && rm -rf /var/lib/apt/lists/*

RUN url="https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz"; \
    sha256="77e5da33bb72aeaef1ba4418b6fe511bc4d041873cbf82e5aa6318740df98717"; \
	wget --progress=dot:giga -O go.tgz.asc "${url}.asc"; \
	wget --progress=dot:giga -O go.tgz "${url}" --progress=dot:giga; \
	echo "$sha256 *go.tgz" | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
    # smoke test \
    go version; \
    # install gopls \
    go install "golang.org/x/tools/gopls@v${GOPLS_VERSION}";

COPY package.json /app/package.json
COPY package-lock.json /app/package-lock.json

RUN npm install --prefix /app --no-audit --no-fund --omit=dev /app

COPY entrypoint.sh /entrypoint.sh

ENV PATH="/app/node_modules/.bin:$PATH"

WORKDIR /workspace
ENTRYPOINT ["/entrypoint.sh"]
CMD ["opencode"]
