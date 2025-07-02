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

COPY package.json /app/package.json
COPY package-lock.json /app/package-lock.json

COPY entrypoint.sh /entrypoint.sh

RUN npm install --prefix /app --no-audit --no-fund --omit=dev /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gosu \
    git \
    python3 \
    python3-pip \
    wget \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/app/node_modules/.bin/opencode"]
