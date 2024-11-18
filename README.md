# Elasticsearch Monitoring

## Description

This service provides custom Telegraf sh plugin which collect metrics from cluster of Elasticsearch.

## Deployment

[Deployment instruction](./documentation/installation-guide/README.md)

## Grafana

### Dashboard exporting

```bash
curl -XGET -k -u admin:admin http://localhost:3000/api/dashboards/db/elasticsearch-6-5-cluster \
  | jq . > dashboard/elasticsearch-6.5-dashboard.json
```

where:

* `admin:admin` is Grafana user login and password
* `http://localhost:3000` is Grafana URL
* `elasticsearch-6-5-cluster` is dashboard name
 
### Dashboard importing

Dashboard can be imported using the following command:

```bash
curl -XPOST \
  -u admin:admin \
  --data @./dashboard/elasticsearch-6.5-dashboard.json \
  -H 'Content-Type: application/json'  \
  -k \
   http://localhost:3000/api/dashboards/db
```

where:

* `admin:admin` is Grafana user login and password
* `http://localhost:3000` is Grafana URL

## Zabbix

Zabbix template for monitoring Elasticsearch cluster state consists of items and triggers 
for monitoring CPU usage, memory usage and state of the cluster.

### Importing Template

Template can be imported in Zabbix UI from templates page (Configuration -> Templates) by using Import button.

### DR Mode

If you have Elasticsearch which is deployed in DR mode you need to create two hosts: 
for left and for right side and to specify the side as value (`left`, `right`) for the macros `{$DR_SIDE}`.
If you have Elasticsearch without DR just leave this macros empty.

## InfluxDB Measurement

### Custom tags, values and measurements

Tags, values and measurements that were added in custom sh scripts.

* `status_code` - code of cluster status:
  * `0` - cluster has GREEN health and all nodes running
  * `6` - cluster has YELLOW health or one ore more nodes failed
  * `10` - cluster has RED health
* `health_code` - code of cluster health 
  * `0` - GREEN
  * `6` - YELLOW
  * `10` - RED
  * `-1` - other status
* `total_number_of_nodes` - variable which is always equal to `ELASTICSEARCH_TOTAL_NODES_COUNT` 
  environment variable
* `project_name` - tag, that contains name of monitored project in OpenShift

### Custom scripts

* `exec-scripts/backup_metric.py` - collect metrics about Elasticsearch snapshots.
* `exec-scripts/dbaas_health_metric.py` - collect metrics about DBaaS cluster health and status.
* `exec-scripts/health_metric.py` - collect metrics about cluster health, status and total nodes count.
* `exec-scripts/replication_metric.py` - collect metrics about replication process.
* `exec-scripts/slow_queries_metric.py` - collect metrics about slow queries to a search engine.