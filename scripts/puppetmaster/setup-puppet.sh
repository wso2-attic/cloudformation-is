#!/usr/bin/env bash
# ----------------------------------------------------------------------------
#
# Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
#
# WSO2 Inc. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# ----------------------------------------------------------------------------

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

set -e

echo ">> Creating puppet-artifacts directory"
mkdir puppet-artifacts

echo ">> Cloning wso2/puppet-common to puppet-artifacts"
git clone --depth=1 https://github.com/wso2/puppet-common puppet-artifacts/puppet-common

echo ">> Creating puppet-artifacts/tmp directory to setup puppet artifacts"
mkdir puppet-artifacts/tmp

export PUPPET_HOME=`pwd`/puppet-artifacts/tmp
echo ">> Set $PUPPET_HOME as temporary puppet home path"

./puppet-artifacts/puppet-common/setup.sh -p is

echo ">> Copy puppet-artifacts to /etc/puppet path"

echo ">> Copy hiera.yaml to /etc/puppet"
cp ./puppet-artifacts/tmp/hiera.yaml /etc/puppet/

echo ">> Copy modules to /etc/puppet/environments/production/"
if [ ! -d /etc/puppet/environments/production ]; then
    mkdir -p /etc/puppet/environments/production/modules
fi
cp -r ./puppet-artifacts/tmp/modules/ /etc/puppet/environments/production/modules

echo ">> Install stdlib module"
puppet module install puppetlabs-stdlib

echo ">> Copy hieradata to /etc/puppet/"
mv ./puppet-artifacts/tmp/hieradata/dev ./puppet-artifacts/tmp/hieradata/production
cp -rL ./puppet-artifacts/tmp/hieradata /etc/puppet/

echo ">> Copy manifests to /etc/puppet/environments/production/"
cp -rL ./puppet-artifacts/tmp/manifests /etc/puppet/environments/production/

