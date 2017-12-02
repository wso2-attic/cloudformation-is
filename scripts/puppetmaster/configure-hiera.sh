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

readonly PATTERN=$2
readonly IS_HOST=$4
readonly DB_HOST=$6
readonly DB_PORT=$8
readonly DB_ENGINE=${10}
readonly DB_USERNAME=${12}
readonly DB_PASSWORD=${14}

# databases
readonly UM_DB="WSO2_USER_DB"
readonly GOV_REG_DB="WSO2_GOV_REG_DB"
readonly CONFIG_REG_DB="WSO2_CONFIG_REG_DB"
readonly IDENTITY_DB="WSO2_IDENTITY_DB"
readonly BPS_DB="WSO2_BPS_DB"
readonly METRICS_DB="WSO2_METRICS_DB"

function get_database_driver_class() {

    local database_driver_class=""
    if [ $DB_ENGINE = "postgres" ]; then
        database_driver_class="org.postgresql.Driver"
    elif [ $DB_ENGINE = "mysql" ]; then
        database_driver_class="com.mysql.jdbc.Driver"
    elif [ $DB_ENGINE = "oracle-se" ]; then
        database_driver_class="com.mysql.jdbc.Driver"
    elif [ $DB_ENGINE = "sqlserver-ex" ]; then
        database_driver_class="com.mysql.jdbc.Driver"
    elif [ $DB_ENGINE = "mariadb" ]; then
        database_driver_class="com.mysql.jdbc.Driver"
    fi
    echo $database_driver_class
}

function get_jdbc_url_prefix() {

    local url_prefix=""
    if [ $DB_ENGINE = "postgres" ]; then
        url_prefix="postgresql"
    elif [ $DB_ENGINE = "mysql" ]; then
        url_prefix="mysql"
    elif [ $DB_ENGINE = "oracle-se" ]; then
        url_prefix="oracle:thin"
    elif [ $DB_ENGINE = "sqlserver-ex" ]; then
        url_prefix="sqlserver"
    elif [ $DB_ENGINE = "mariadb" ]; then
        url_prefix="mariadb"
    fi
    echo $url_prefix
}

function configure() {

    local db_driver_class=$(get_database_driver_class)
    local db_url_prefix=$(get_jdbc_url_prefix)
    local db_driver_binary="$(find downloads/jdbc/ -type f -name *.jar -printf "%f\n")"

    echo ">> Configuring /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml"
    sed -i 's/^\(wso2::hostname:[[:space:]]*\).*$/\1'${IS_HOST}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\(wso2::mgt_hostname:[[:space:]]*\).*$/\1'${IS_HOST}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*sso_service_url:[[:space:]]*\).*$/\1https:\/\/'${IS_HOST}':443\/samlsso/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*consumer_service_url:[[:space:]]*\).*$/\1https:\/\/'${IS_HOST}':443\/acs/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*driver_class_name:[[:space:]]*\).*$/\1'${db_driver_class}'/g' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*username:[[:space:]]*\).*$/\1'${DB_USERNAME}'/g' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*password:[[:space:]]*\).*$/\1'${DB_PASSWORD}'/g' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*url:[[:space:]]*\).*WSO2_CONFIG_REG_DB.*$/\1jdbc:'${db_url_prefix}':\/\/'${DB_HOST}':'${DB_PORT}'\/'${CONFIG_REG_DB}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*url:[[:space:]]*\).*WSO2_GOV_REG_DB.*$/\1jdbc:'${db_url_prefix}':\/\/'${DB_HOST}':'${DB_PORT}'\/'${GOV_REG_DB}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*url:[[:space:]]*\).*WSO2_IDENTITY_DB.*$/\1jdbc:'${db_url_prefix}':\/\/'${DB_HOST}':'${DB_PORT}'\/'${IDENTITY_DB}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*url:[[:space:]]*\).*WSO2_USER_DB.*$/\1jdbc:'${db_url_prefix}':\/\/'${DB_HOST}':'${DB_PORT}'\/'${UM_DB}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*url:[[:space:]]*\).*WSO2_BPS_DB.*$/\1jdbc:'${db_url_prefix}':\/\/'${DB_HOST}':'${DB_PORT}'\/'${BPS_DB}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*url:[[:space:]]*\).*WSO2METRICS_DB.*$/\1jdbc:'${db_url_prefix}':\/\/'${DB_HOST}':'${DB_PORT}'\/'${METRICS_DB}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*-.*repository\/components\/lib\/\).*$/\1'${db_driver_binary}'\"/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    echo ">> Completed configuring /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml"
}

configure


