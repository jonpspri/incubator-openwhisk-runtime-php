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

set -ex

# Build script for Travis-CI.

SCRIPTDIR="$(cd "$(dirname "$0")" && pwd)"
ROOTDIR="$(cd "$SCRIPTDIR/../.." && pwd)"
WHISKDIR="$(cd "$ROOTDIR/../openwhisk" && pwd)"

export OPENWHISK_HOME="$WHISKDIR"

IMAGE_PREFIX="testing"

# Deploy OpenWhisk
cd "$WHISKDIR/ansible"
ANSIBLE_ARGS=( -i "${ROOTDIR}/ansible/environments/local" -e "docker_image_prefix='${IMAGE_PREFIX}'" )
ansible-playbook "${ANSIBLE_ARGS[@]}" setup.yml
ansible-playbook "${ANSIBLE_ARGS[@]}" prereq.yml
ansible-playbook "${ANSIBLE_ARGS[@]}" couchdb.yml
ansible-playbook "${ANSIBLE_ARGS[@]}" initdb.yml
ansible-playbook "${ANSIBLE_ARGS[@]}" wipe.yml
ansible-playbook "${ANSIBLE_ARGS[@]}" openwhisk.yml -e cli_installation_mode=remote

docker images
docker ps

cat "$WHISKDIR/whisk.properties"
curl -s -k https://172.17.0.1 | jq .
curl -s -k https://172.17.0.1/api/v1 | jq .

#Deployment
WHISK_APIHOST="172.17.0.1"
WHISK_AUTH="$(cat "${WHISKDIR}/ansible/files/auth.guest")"
WHISK_CLI="${WHISKDIR}/bin/wsk -i"

${WHISK_CLI} property set --apihost "${WHISK_APIHOST}" --auth "${WHISK_AUTH}" 
${WHISK_CLI} property get


