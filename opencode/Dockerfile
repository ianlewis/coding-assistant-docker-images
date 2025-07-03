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

FROM node:22.17.0-slim@sha256:dd8deb1d3ed48e5641b5e69d597670e2e454b85e1674a2a4405a98457a9bdc55

ENV PATH=/usr/local/go/bin:$PATH

ENV GOLANG_VERSION=1.24.4
ENV GOPLS_VERSION=0.19.1

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Install dependencies
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    curl=7.88.1-10+deb12u12 \
    gosu=1.14-1+b10 \
    git=1:2.39.5-0+deb12u2 \
    python3=3.11.2-1+b1 \
    python3-pip=23.0.1+dfsg-1 \
    wget=1.21.3-1+deb12u1 \
    zip=3.0-13 \
    unzip=6.0-28 \
    && rm -rf /var/lib/apt/lists/*

RUN url='https://dl.google.com/go/go1.24.4.linux-amd64.tar.gz'; \
    sha256='77e5da33bb72aeaef1ba4418b6fe511bc4d041873cbf82e5aa6318740df98717'; \
	wget --progress=dot:giga -O go.tgz.asc "$url.asc"; \
	wget --progress=dot:giga -O go.tgz "$url" --progress=dot:giga; \
	echo "$sha256 *go.tgz" | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
# smoke test
    go version; \
# install gopls
    go install golang.org/x/tools/gopls@v${GOPLS_VERSION};

COPY package.json /app/package.json
COPY package-lock.json /app/package-lock.json

COPY entrypoint.sh /entrypoint.sh

RUN npm install --prefix /app --no-audit --no-fund --omit=dev /app

WORKDIR /workspace
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/app/node_modules/.bin/opencode"]
