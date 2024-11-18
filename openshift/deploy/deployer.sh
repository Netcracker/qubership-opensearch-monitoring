#!/usr/bin/env bash

source ./deployment_utils/scripts/openshift.sh
source ./deployment_utils/scripts/affinity.sh

#Creates secret.
create_secret() {
  echo "=> Creating secret..."
  local secret_name=${SERVICE_NAME}-secret
  remove_if_exists "secret" $secret_name
  echo "=> Searching Elasticsearch secret..."
  local es_secret_name=${ELASTICSEARCH_HOST}-secret
  local grep_result=$(oc get secrets -n ${OS_PROJECT} | grep ${es_secret_name})

  if [ -z "$grep_result" ]; then
    es_secret_name=${secret_name}
    local es_auth=""
    if [[ -n "$ELASTICSEARCH_USERNAME" && -n "$ELASTICSEARCH_PASSWORD" ]]; then
      es_auth="$ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD"
    fi
    oc create secret generic "$secret_name" \
      --from-literal=es-cred-for-internal-clients="$es_auth" \
      --from-literal=sm-db-username="$SM_DB_USERNAME" \
      --from-literal=sm-db-password="$SM_DB_PASSWORD" \
      -n ${OS_PROJECT}
  else
    echo "Elasticsearch secret [$es_secret_name] is found"
    oc create secret generic "$secret_name" \
      --from-literal=sm-db-username="$SM_DB_USERNAME" \
      --from-literal=sm-db-password="$SM_DB_PASSWORD" \
      -n ${OS_PROJECT}
  fi
  ES_SECRET_NAME=${es_secret_name}
}

prepare_deployment() {
  telegraf_deploy_pod=$(oc get pod | grep -e "${SERVICE_NAME}-[0-9]*-deploy" | awk '{print $1}')
  if ! [ -z ${telegraf_deploy_pod} ]; then
    oc delete pod ${telegraf_deploy_pod}
  fi
  remove_dc ${SERVICE_NAME}
  remove_config_map ${SERVICE_NAME}-configuration
  remove_svc ${SERVICE_NAME}

  oc create configmap ${SERVICE_NAME}-configuration --from-file=config=./configs/telegraf.conf

  if [[ ${TLS_HTTP_ENABLED} == "true" ]]; then
    ELASTICSEARCH_PROTOCOL="https"
  else
    ELASTICSEARCH_PROTOCOL="http"
  fi
}

#Prepare custom labels
#
#$1 - node labels in yaml file which should be replaced to custom labels
prepare_custom_labels() {
  local custom_labels=$1

  temp_template=$(cat ./templates/telegraf-template.yaml)
  check_affinity_is_enabled
  if [[ "$is_affinity_enabled" = true ]]; then
    prepare_custom_affinity_rules "$custom_labels" "./templates/telegraf-template.yaml"
  else
    prepare_node_selector_rules "$custom_labels" "./templates/telegraf-template.yaml"
  fi

  echo "$temp_template"
}

#Processing template yaml, create service and dc
deployment() {
  generate_influx_db_name
  echo "=> Processing template..."
  local processed_template=$(
    prepare_custom_labels "${NODE_LABELS}" | oc process -f - --output='yaml' \
       IMAGE="${IMAGE:-$image}" \
       MEMORY_REQUEST="${MEMORY_REQUEST:-$memory_request}" \
       CPU_REQUEST="${CPU_REQUEST:-$cpu_request}" \
       MEMORY_LIMIT="${MEMORY_LIMIT:-$memory_limit}" \
       CPU_LIMIT="${CPU_LIMIT:-$cpu_limit}" \
       ELASTICSEARCH_HOST="${ELASTICSEARCH_HOST:-$elasticsearch_host}" \
       ELASTICSEARCH_PORT="${ELASTICSEARCH_PORT:-$elasticsearch_port}" \
       ELASTICSEARCH_DBAAS_ADAPTER_HOST="${ELASTICSEARCH_DBAAS_ADAPTER_HOST:-$elasticsearch_dbaas_adapter_host}" \
       ELASTICSEARCH_DBAAS_ADAPTER_PORT="${ELASTICSEARCH_DBAAS_ADAPTER_PORT:-$elasticsearch_dbaas_adapter_port}" \
       SM_DB_NAME="${SM_DB_NAME:-$sm_db_name}" \
       SM_DB_HOST="${SM_DB_HOST:-$sm_db_host}" \
       ELASTICSEARCH_DATA_NODES_COUNT="${ELASTICSEARCH_DATA_NODES_COUNT:-$elasticsearch_data_nodes_count}" \
       ELASTICSEARCH_TOTAL_NODES_COUNT="${ELASTICSEARCH_TOTAL_NODES_COUNT:-$elasticsearch_total_nodes_count}" \
       ELASTICSEARCH_EXEC_PLUGIN_TIMEOUT="$ELASTICSEARCH_EXEC_PLUGIN_TIMEOUT" \
       OS_PROJECT="${OS_PROJECT:-$os_project}" \
       SERVICE_NAME="${SERVICE_NAME}" \
       ELASTICSEARCH_PROTOCOL="${ELASTICSEARCH_PROTOCOL}" \
       ES_SECRET_NAME="${ES_SECRET_NAME}"
    )
  if [ $? -ne 0 ]; then
    echo "Processing template failed"
    echo -ne "${processed_template}"
    exit 1
  fi
  echo -ne "${processed_template}" | oc create -f -
  echo -ne "${processed_template}" | oc apply -f -
  if [ $? -ne 0 ]; then
    echo "Unable to apply new configuration"
    echo -ne "${processed_template}"
    exit 1
  fi
}

#Generates database name if it isn't specified.
generate_influx_db_name() {
  if [[ -z "${SM_DB_NAME}" ]]; then
    SM_DB_NAME=$(echo ${OS_HOST} | \
      sed -e 's/https:\/\//cloud_/' \
      -e 's/:[0-9]*//' \
      -e 's/\./_/g' \
      -e 's/\-/_/g'
    )
  fi
}

#Deploy elasticsearch-monitoring to OpenShift.
run() {
  login_to_openshift
  create_project_if_absent
  prepare_deployment
  create_secret
  deployment
  wait_until_pods_are_started "component=elasticsearch-monitoring,name=$SERVICE_NAME" 1 300
  echo "=> Congratulations! All done"
}