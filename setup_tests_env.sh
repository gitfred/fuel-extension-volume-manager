#!/bin/bash

#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

set -eu

export CLONEMAP=/tmp/clone-map-volman.yml
export FUEL_WEB_PATH=${FUEL_WEB_PATH:-/tmp/fuel-web}
export FUEL_VOLUME_MANAGER_EXTENSION_PATH=${FUEL_VOLUME_MANAGER_EXTENSION_PATH:-/tmp/fuel-extension-volume-manager}
export NAILGUN_TOOLS_PATH=${NAILGUN_TOOLS_PATH:-$FUEL_WEB_PATH/nailgun/tools}


export FUEL_WEB_PROJECT=${FUEL_WEB_PROJECT:-openstack/fuel-web}
export FUEL_VOLUME_MANAGER_EXTENSION_PROJECT=${FUEL_VOLUME_MANAGER_EXTENSION_PROJECT:-openstack/fuel-extension-volume-manager}



export NAILGUN_DB=${NAILGUN_DB:-openstack-citest}
export NAILGUN_DB_USER=${NAILGUN_DB_USER:-openstack-citest}
export NAILGUN_DB_USERPW=${NAILGUN_DB_USERPW:-openstack-citest}
export NAILGUN_DB_PORT=${NAILGUN_DB_PORT:-5432}
export NAILGUN_DB_HOST=${NAILGUN_DB_HOST:-127.0.0.1}

cat > $CLONEMAP << EOF
clonemap:
- name: ([A-Za-z0-9-_]+)/fuel-web
  dest: $FUEL_WEB_PATH
- name: ([A-Za-z0-9-_]+)/fuel-extension-volume-manager
  dest: $FUEL_VOLUME_MANAGER_EXTENSION_PATH
EOF

cat > $NAILGUN_CONFIG << EOF
clonemap:
DATABASE:
  engine: "postgresql"
  host: $NAILGUN_DB_HOST
  name: $NAILGUN_DB
  passwd: $NAILGUN_DB_USERPW
  port: $NAILGUN_DB_PORT
  user: $NAILGUN_DB_USER
EOF

rm -rf $FUEL_WEB_PATH $FUEL_VOLUME_MANAGER_EXTENSION_PATH

zuul-cloner \
    git://github.com \
    $FUEL_WEB_PROJECT \
    $FUEL_VOLUME_MANAGER_EXTENSION_PROJECT \
    -m $CLONEMAP \
    --project-branch $FUEL_WEB_PROJECT=wo-volman

pip install -e $FUEL_WEB_PATH/nailgun
pip install -e $FUEL_VOLUME_MANAGER_EXTENSION_PATH
bash -c "$NAILGUN_TOOLS_PATH/env.sh prepare_nailgun_env"
bash -c "$NAILGUN_TOOLS_PATH/env.sh prepare_nailgun_database"
bash -c "$NAILGUN_TOOLS_PATH/env.sh prepare_nailgun_server"