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

FROM ghcr.io/ianlewis/coding-assistant-docker-images-base:latest@sha256:96ecdb5558e90500293589473df78337ba6ca9ef4660e1c3cee2568e82b10e33

COPY package.json /app/package.json
COPY package-lock.json /app/package-lock.json

RUN npm install --prefix /app --no-audit --no-fund --omit=dev /app

COPY config.sh /config.sh

ENV PATH="/app/node_modules/.bin:$PATH"

CMD ["claude"]
