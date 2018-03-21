#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -eux

# Build script for Travis-CI.

SCRIPTDIR="$(cd "$(dirname "$0")" && pwd)"
ROOTDIR="$(cd "$SCRIPTDIR/../.." && pwd)"
WHISKDIR="$(cd "$ROOTDIR/../openwhisk" && pwd)"

export OPENWHISK_HOME="$WHISKDIR"

IMAGE_PREFIX="$1"
RUNTIME_VERSION="$2"
IMAGE_TAG="$3"

if [ "${RUNTIME_VERSION}" == "7" ]; then
  # TODO: Is this depricated?
  RUNTIME="php7Action"
elif [ "${RUNTIME_VERSION}" == "7.1" ]; then
  RUNTIME="php7.1Action"
fi

if [[ ! -z ${RUNTIME} ]]; then
  ./gradlew --console=plain \
    ":core:${RUNTIME}:distDocker" \
    -PdockerImagePrefix="${IMAGE_PREFIX}" \
    -PdockerImageTag="${IMAGE_TAG}"
fi
