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

FROM ghcr.io/ianlewis/coding-assistant-docker-images-base:latest@sha256:0396c834fb896352be087ae730b06bd3d9d21bc1d9a2003f1f7f61d554efb166
ARG TARGETPLATFORM
ARG BUILDPLATFORM


COPY package.json /app/package.json
COPY package-lock.json /app/package-lock.json

WORKDIR /app
RUN npm clean-install --no-fund --omit=dev

COPY config.sh /config.sh

ENV PATH="/app/node_modules/.bin:$PATH"

WORKDIR /workspace
CMD ["claude"]
