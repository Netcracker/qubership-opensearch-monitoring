import unittest
from unittest import mock

from dbaas_health_metric import _collect_metrics

ELASTICSEARCH_DBAAS_ADAPTER_URL = "http://elasticsearch-dbaas-adapter:8080"


class TestDbaasHealthMetric(unittest.TestCase):

    def test_metrics_if_dbaas_adapter_is_not_available(self):
        expected_result = 'elasticsearch_dbaas_health status=1,elastic_cluster_status=3'
        actual_result = _collect_metrics(ELASTICSEARCH_DBAAS_ADAPTER_URL)
        self.assertEqual(expected_result, actual_result)

    @mock.patch('dbaas_health_metric._get_health_data', mock.Mock(side_effect=lambda url:
        {"status": "UP", "elasticCluster": {"status": "UP"}, "physicalDatabaseRegistration": {"status": "OK"}}
        if url == ELASTICSEARCH_DBAAS_ADAPTER_URL else ''))
    def test_metrics_if_elasticsearch_dbaas_adapter_is_available(self):
        expected_result = 'elasticsearch_dbaas_health status=5,elastic_cluster_status=5'
        actual_result = _collect_metrics(ELASTICSEARCH_DBAAS_ADAPTER_URL)
        self.assertEqual(expected_result, actual_result)

    @mock.patch('dbaas_health_metric._get_health_data', mock.Mock(side_effect=lambda url:
        {"status": "UP", "opensearchHealth": {"status": "UP"}, "dbaasAggregatorHealth": {"status": "OK"}}
        if url == ELASTICSEARCH_DBAAS_ADAPTER_URL else ''))
    def test_metrics_if_opensearch_dbaas_adapter_is_available(self):
        expected_result = 'elasticsearch_dbaas_health status=5,elastic_cluster_status=5'
        actual_result = _collect_metrics(ELASTICSEARCH_DBAAS_ADAPTER_URL)
        self.assertEqual(expected_result, actual_result)


if __name__ == '__main__':
    unittest.main()
