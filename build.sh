#!/bin/sh

#DP hack
export DISABLE_AUTO_CERTIFICATE_INSTALLATION=true

BUILD_SH_TARGET_DIR=target

#Docker artifacts
DOCKER_FILE=docker/Dockerfile

for docker_image_name in ${DOCKER_NAMES}; do
  docker build \
    --file=${DOCKER_FILE} \
    --pull \
    -t ${docker_image_name} \
    .
done

# Grafana dashboards
ELASTICSEARCH_2_3_DASHBOARD_FILE_PATH=grafana/elasticsearch-2.3-dashboard.json
ELASTICSEARCH_2_3_DASHBOARD_ARTIFACT_NAME=elasticsearch-2.3-grafana-dashboard

ELASTICSEARCH_5_1_DASHBOARD_FILE_PATH=grafana/elasticsearch-5.1-dashboard.json
ELASTICSEARCH_5_1_DASHBOARD_ARTIFACT_NAME=elasticsearch-5.1-grafana-dashboard

ELASTICSEARCH_5_6_DASHBOARD_FILE_PATH=grafana/elasticsearch-5.6-dashboard.json
ELASTICSEARCH_5_6_DASHBOARD_ARTIFACT_NAME=elasticsearch-5.6-grafana-dashboard

ELASTICSEARCH_6_5_DASHBOARD_FILE_PATH=grafana/elasticsearch-6.5-dashboard.json
ELASTICSEARCH_6_5_DASHBOARD_ARTIFACT_NAME=elasticsearch-6.5-grafana-dashboard

ELASTICSEARCH_MIN_DASHBOARD_FILE_PATH=grafana/elasticsearch-min-dashboard.json
ELASTICSEARCH_MIN_DASHBOARD_ARTIFACT_NAME=elasticsearch-min-grafana-dashboard

# Zabbix templates
ZABBIX_ELASTICSEARCH_TEMPLATE_FILE_PATH=zabbix/template/template_Elasticsearch.xml
ZABBIX_ELASTICSEARCH_TEMPLATE_ARTIFACT_NAME=elasticsearch-zabbix-template

# Files artifacts
JENKINS_JOB_AND_DEPENDENCIES_ARTIFACT_NAME=elasticsearch-telegraf-deploy-artifacts

mkdir ${BUILD_SH_TARGET_DIR}

# Download deployment utils
./download_deployment_utils.sh

zip -r ${BUILD_SH_TARGET_DIR}/${ELASTICSEARCH_2_3_DASHBOARD_ARTIFACT_NAME}.zip ${ELASTICSEARCH_2_3_DASHBOARD_FILE_PATH}
zip -r ${BUILD_SH_TARGET_DIR}/${ELASTICSEARCH_5_1_DASHBOARD_ARTIFACT_NAME}.zip ${ELASTICSEARCH_5_1_DASHBOARD_FILE_PATH}
zip -r ${BUILD_SH_TARGET_DIR}/${ELASTICSEARCH_5_6_DASHBOARD_ARTIFACT_NAME}.zip ${ELASTICSEARCH_5_6_DASHBOARD_FILE_PATH}
zip -r ${BUILD_SH_TARGET_DIR}/${ELASTICSEARCH_6_5_DASHBOARD_ARTIFACT_NAME}.zip ${ELASTICSEARCH_6_5_DASHBOARD_FILE_PATH}
zip -r ${BUILD_SH_TARGET_DIR}/${ELASTICSEARCH_MIN_DASHBOARD_ARTIFACT_NAME}.zip ${ELASTICSEARCH_MIN_DASHBOARD_FILE_PATH}
zip -r ${BUILD_SH_TARGET_DIR}/${ZABBIX_ELASTICSEARCH_TEMPLATE_ARTIFACT_NAME}.zip ${ZABBIX_ELASTICSEARCH_TEMPLATE_FILE_PATH}

zip -r \
  ${BUILD_SH_TARGET_DIR}/${JENKINS_JOB_AND_DEPENDENCIES_ARTIFACT_NAME}.zip \
  jenkins openshift/deploy
