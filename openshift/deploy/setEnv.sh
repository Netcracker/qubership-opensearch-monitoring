#!/usr/bin/env bash

#################################################################
# Environment variables
#################################################################
#
# OS_PROJECT
# IMAGE
#
# MEMORY_REQUEST
# CPU_REQUEST
# MEMORY_LIMIT
# CPU_LIMIT
#
# OS_HOST
# OS_ADMINISTRATOR_NAME
# OS_ADMINISTRATOR_PASSWORD
#
# NODE_LABELS
# REQUIRED_AFFINITY
# PREFERRED_AFFINITY
# REQUIRED_ANTI_AFFINITY
# PREFERRED_ANTI_AFFINITY
#
# SM_DB_HOST
# SM_DB_NAME
# SM_DB_USERNAME
# SM_DB_PASSWORD
# ELASTICSEARCH_HOST
# ELASTICSEARCH_PORT
# ELASTICSEARCH_DBAAS_ADAPTER_HOST
# ELASTICSEARCH_DBAAS_ADAPTER_PORT
#
# ELASTICSEARCH_DATA_NODES_COUNT
# ELASTICSEARCH_TOTAL_NODES_COUNT
# ELASTICSEARCH_EXEC_PLUGIN_TIMEOUT

# Initializes environment variables.
init() {
  local os_project=
  local service_name=elasticsearch-monitoring
  local image=telegraf-elasticsearch:latest

  local memory_request=256Mi
  local cpu_request=200m
  local memory_limit=256Mi
  local cpu_limit=200m

  local os_host=
  local os_administrator_name=
  local os_administrator_password=

  local sm_db_host=http://influxdb:8086
  local sm_db_name=
  local sm_db_username=
  local sm_db_password=
  local elasticsearch_host=elasticsearch
  local elasticsearch_port=9200
  local elasticsearch_dbaas_adapter_host=dbaas-elasticsearch-adapter
  local elasticsearch_dbaas_adapter_port=8080
  local elasticsearch_username=
  local elasticsearch_password=
  local tls_http_enabled=false

  local elasticsearch_data_nodes_count=
  local elasticsearch_total_nodes_count=
  local elasticsearch_exec_plugin_timeout="15s"

  local node_labels=

  local required_affinity=
  local preferred_affinity=
  local required_anti_affinity=
  local preferred_anti_affinity=

  OS_PROJECT=${ELASTICSEARCH_MONITORING_OS_PROJECT:-${OS_PROJECT:-$os_project}}
  SERVICE_NAME=${ELASTICSEARCH_MONITORING_SERVICE_NAME:-${SERVICE_NAME:-$service_name}}
  IMAGE=${ELASTICSEARCH_MONITORING_IMAGE:-${IMAGE:-$image}}

  MEMORY_REQUEST=${ELASTICSEARCH_MONITORING_MEMORY_REQUEST:-${MEMORY_REQUEST:-$memory_request}}
  CPU_REQUEST=${ELASTICSEARCH_MONITORING_CPU_REQUEST:-${CPU_REQUEST:-$cpu_request}}
  MEMORY_LIMIT=${ELASTICSEARCH_MONITORING_MEMORY_LIMIT:-${MEMORY_LIMIT:-$memory_limit}}
  CPU_LIMIT=${ELASTICSEARCH_MONITORING_CPU_LIMIT:-${CPU_LIMIT:-$cpu_limit}}

  OS_HOST=${OS_HOST:-$os_host}
  OS_ADMINISTRATOR_NAME=${OS_ADMINISTRATOR_NAME:-$os_administrator_name}
  OS_ADMINISTRATOR_PASSWORD=${OS_ADMINISTRATOR_PASSWORD:-$os_administrator_password}

  SM_DB_HOST=${ELASTICSEARCH_MONITORING_SM_DB_HOST:-${SM_DB_HOST:-$sm_db_host}}
  SM_DB_NAME=${ELASTICSEARCH_MONITORING_SM_DB_NAME:-${SM_DB_NAME:-$sm_db_name}}
  SM_DB_USERNAME=${ELASTICSEARCH_MONITORING_SM_DB_USERNAME:-${SM_DB_USERNAME:-$sm_db_username}}
  SM_DB_PASSWORD=${ELASTICSEARCH_MONITORING_SM_DB_PASSWORD:-${SM_DB_PASSWORD:-$sm_db_password}}
  ELASTICSEARCH_HOST=${ELASTICSEARCH_MONITORING_ELASTICSEARCH_HOST:-${ELASTICSEARCH_HOST:-$elasticsearch_host}}
  ELASTICSEARCH_PORT=${ELASTICSEARCH_MONITORING_ELASTICSEARCH_PORT:-${ELASTICSEARCH_PORT:-$elasticsearch_port}}
  ELASTICSEARCH_DBAAS_ADAPTER_HOST=${ELASTICSEARCH_MONITORING_ELASTICSEARCH_DBAAS_ADAPTER_HOST:-${ELASTICSEARCH_DBAAS_ADAPTER_HOST:-$elasticsearch_dbaas_adapter_host}}
  ELASTICSEARCH_DBAAS_ADAPTER_PORT=${ELASTICSEARCH_MONITORING_ELASTICSEARCH_DBAAS_ADAPTER_PORT:-${ELASTICSEARCH_DBAAS_ADAPTER_PORT:-$elasticsearch_dbaas_adapter_port}}

  ELASTICSEARCH_DATA_NODES_COUNT=${ELASTICSEARCH_MONITORING_ELASTICSEARCH_DATA_NODES_COUNT:-${ELASTICSEARCH_DATA_NODES_COUNT:-$elasticsearch_data_nodes_count}}
  ELASTICSEARCH_TOTAL_NODES_COUNT=${ELASTICSEARCH_MONITORING_ELASTICSEARCH_TOTAL_NODES_COUNT:-${ELASTICSEARCH_TOTAL_NODES_COUNT:-$elasticsearch_total_nodes_count}}
  ELASTICSEARCH_EXEC_PLUGIN_TIMEOUT=${ELASTICSEARCH_MONITORING_ELASTICSEARCH_EXEC_PLUGIN_TIMEOUT:-${ELASTICSEARCH_EXEC_PLUGIN_TIMEOUT:-$elasticsearch_exec_plugin_timeout}}

  TLS_HTTP_ENABLED=${TLS_HTTP_ENABLED:-$tls_http_enabled}
  ELASTICSEARCH_USERNAME=${ELASTICSEARCH_MONITORING_ELASTICSEARCH_USERNAME:-${ELASTICSEARCH_USERNAME:-$elasticsearch_username}}
  ELASTICSEARCH_PASSWORD=${ELASTICSEARCH_MONITORING_ELASTICSEARCH_PASSWORD:-${ELASTICSEARCH_PASSWORD:-$elasticsearch_password}}

  NODE_LABELS=${ELASTICSEARCH_MONITORING_NODE_LABELS:-${NODE_LABELS:-$node_labels}}

  REQUIRED_AFFINITY=${ELASTICSEARCH_MONITORING_REQUIRED_AFFINITY:-${REQUIRED_AFFINITY:-$required_affinity}}
  PREFERRED_AFFINITY=${ELASTICSEARCH_MONITORING_PREFERRED_AFFINITY:-${PREFERRED_AFFINITY:-$preferred_affinity}}
  REQUIRED_ANTI_AFFINITY=${ELASTICSEARCH_MONITORING_REQUIRED_ANTI_AFFINITY:-${REQUIRED_ANTI_AFFINITY:-$required_anti_affinity}}
  PREFERRED_ANTI_AFFINITY=${ELASTICSEARCH_MONITORING_PREFERRED_ANTI_AFFINITY:-${PREFERRED_ANTI_AFFINITY:-$preferred_anti_affinity}}
}

init

