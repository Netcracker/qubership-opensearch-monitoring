# Deploy Elasticsearch-Monitoring

## Environment Parameters
You can change the environment variables in `setEnv.sh` script.

* `OS_PROJECT`

    The name of the OpenShift project, new or existing one (**required**).

* `SERVICE_NAME`

    The service name in OpenShift (default: `elasticsearch-monitoring`).

* `IMAGE`

    Docker image for deployment (default: `artifactorycn.netcracker.com:17023/telegraf/telegraf-elasticsearch:latest`)

* `MEMORY_REQUEST`

    The minimum amount of memory the container should use. The value can be specified with SI suffixes 
    (E, P, T, G, M, K, m) or their power-of-two-equivalents (Ei, Pi, Ti, Gi, Mi, Ki). (default: `256Mi`)

* `CPU_REQUEST`

    The minimum number of CPUs the container should use (default: `200m`).
    
* `MEMORY_LIMIT`

    The maximum amount of memory the container can use. The value can be specified with SI suffixes 
    (E, P, T, G, M, K, m) or their power-of-two-equivalents (Ei, Pi, Ti, Gi, Mi, Ki). (default: `256Mi`)

* `CPU_LIMIT`

    The maximum number of CPUs the container can use (default: `200m`).
    
* `OS_HOST`

    The URL of the OpenShift server, for example, <https://search.openshift.sdntest.netcracker.com:8443> 
    (**required**).

* `OS_ADMINISTRATOR_NAME`

    The name of the OpenShift user, a new or existing one.
    If the user and project exists, then  the user should be the owner or administrator of the project.
  
* `OS_ADMINISTRATOR_PASSWORD`

    The password of the OpenShift user.
    
* `SM_DB_HOST`

    The host of the System Monitoring database. The default value is ```http://influxdb:8086```.

* `SM_DB_NAME`

    The name of the database in System Monitoring. If the parameter is not specified, it is generated from `OS_HOST`.
    For example, with URL ```https://search.openshift.sdntest.example.com:8443``` the generated db name is
    `cloud_search_openshift_sdntest_example_com`.

* `SM_DB_USERNAME`

    The name of the database user in System Monitoring. The parameter should be specified if authentication is enabled in System Monitoring.

* `SM_DB_PASSWORD`

    The password of the database user in System Monitoring. The parameter should be specified if authentication is enabled in System Monitoring.

* `ELASTICSEARCH_HOST`

    The hostname of monitored Elasticsearch (default: `elasticsearch`).

* `ELASTICSEARCH_PORT`

    The http port of monitored Elasticsearch (default: `9200`).
    
* `ELASTICSEARCH_USERNAME`

    Username for Elasticsearch authentication. If you don't specify `ELASTICSEARCH_USERNAME` and `ELASTICSEARCH_PASSWORD` 
    variables then Elasticsearch secret (if it exists) will be used for authentication.
    
* `ELASTICSEARCH_PASSWORD`

    Password for Elasticsearch authentication. If you don't specify `ELASTICSEARCH_USERNAME` and `ELASTICSEARCH_PASSWORD` 
    variables then Elasticsearch secret (if it exists) will be used for authentication.
    
* `TLS_HTTP_ENABLED`

    Parameter determines whether TLS encryption is enabled for Elasticsearch HTTP interface  (default: `false`).
    
* `ELASTICSEARCH_DBAAS_ADAPTER_HOST`

    The host of monitored DBaaS Elasticsearch adapter (default: `dbaas-elasticsearch-adapter`)
    
* `ELASTICSEARCH_DBAAS_ADAPTER_PORT`

    The http port of monitored DBaaS Elasticsearch adapter (default: `8080`)

* `ELASTICSEARCH_DATA_NODES_COUNT`

    The number of Elasticsearch data nodes. It's required for smoke tests index settings.

* `ELASTICSEARCH_TOTAL_NODES_COUNT`

    The number of Elasticsearch data nodes. It's necessary if information about failed nodes is required.
    
* `ELASTICSEARCH_EXEC_PLUGIN_TIMEOUT`

    The value of timeout for Elasticsearch exec telegraf plugin (default: `15s`).

* `NODE_LABELS`

    The value specifies custom required node affinity rules that allow to schedule the pod onto an 
    OpenShift node only if that node has labels with specified keys and values. You can enter a list of node labels 
    separated by comma `node_labels="region=primary,site=left"`. It's necessary to screen "~" symbol in list.
    
* `REQUIRED_AFFINITY` 

    The value specifies custom required pod affinity rules that allow to schedule the pod onto an 
    OpenShift node only if that node has at least one already running pod that has labels 
    with specified keys and values. For example, `required_affinity="component=elasticsearch"`.

* `PREFERRED_AFFINITY` 

    The value specifies custom preferred pod affinity rules that says that the pod prefers to be scheduled 
    onto an OpenShift node if that node has already running pod that has labels with specified keys and values. 
    For example, `preferred_affinity="component=elasticsearch"`. Default value is `component=elasticsearch`.

* `REQUIRED_ANTI_AFFINITY` 

    The value specifies custom required pod anti-affinity rules that don't allow to schedule the pod onto an 
    OpenShift node if that node has at least one already running pod that has labels with specified keys 
    and values. For example, `required_anti_affinity="component=elasticsearch-monitoring"`. Default value is `component=elasticsearch-monitoring`.

* `PREFERRED_ANTI_AFFINITY`

    The value specifies custom preferred pod anti-affinity rules that says that the pod prefers not to be scheduled 
    onto an OpenShift node if that node has already running pod that has labels with specified keys and values. 
    For example, `preferred_anti_affinity="component=elasticsearch-monitoring"`.

The `REQUIRED_AFFINITY`, `PREFERRED_AFFINITY`, `REQUIRED_ANTI_AFFINITY`, `PREFERRED_ANTI_AFFINITY`
parameters are available since 3.11.0 OpenShift version.
    
## Deployment

### Prerequisites

* [bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) is available.
* [oc](https://github.com/openshift/origin/releases) is installed.

### Steps

1. Clone repository
    ```
    git clone git@git.netcracker.com:Personal.Streaming.Platform/elasticsearch-telegraf.git
    ```
2. Download and extract deployment utils
    ```
    chmod +x download_deployment_utils.sh
    ./download_deployment_utils.sh
    ```
3. `cd` to deploy directory
    ```
    cd openshift/deploy
    ```
4. Make sure script files can be executed, i.e. do `chmod +x` on them:
    ```
    chmod +x setEnv.sh
    chmod +x deployer.sh
    chmod +x install.sh
    ```
5. Set environment variables in `setEnv.sh`.
    ```bash
    # Initializes environment variables.
    init() {
      local os_project=mano-platform-elk-develop
      local service_name=elasticsearch-monitoring
      local image=artifactorycn.netcracker.com:17023/telegraf/telegraf-elasticsearch:latest

      local memory_request=256Mi
      local cpu_request=200m
      local memory_limit=256Mi
      local cpu_limit=200m

      local os_host=https://paas-apps2.openshift.sdntest.netcracker.com:8443
      local os_administrator_name=admin
      local os_administrator_password=admin

      local sm_db_host=http://system-monitor-staging.openshift.sdntest.netcracker.com:8086
      local sm_db_name=cloud_paas_apps2_openshift_sdntest_netcracker_com
      local sm_db_username=
      local sm_db_password=
      local elasticsearch_host=elasticsearch
      local elasticsearch_port=9200
      local elasticsearch_dbaas_adapter_host=dbaas-elasticsearch-adapter
      local elasticsearch_dbaas_adapter_port=8080
      local elasticsearch_username=
      local elasticsearch_password=
      local tls_http_enabled=false

      local elasticsearch_data_nodes_count=3
      local elasticsearch_total_nodes_count=3
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
    ```
6. You need to perform command to start Elasticsearch-Monitoring deployment:
    ```
    ./install.sh
    ```