import unittest
from unittest import mock

from requests import Response

from health_metric import _collect_metrics

ELASTICSEARCH_URL = 'http://elasticsearch:9092'


class TestHealthMetric(unittest.TestCase):

    def test_metrics_when_elasticsearch_is_not_available(self):
        expected_message = 'elasticsearch_cluster_health status_code=10,health_code=-1,total_number_of_nodes=3,' \
                           'number_of_nodes=0i'
        actual_message = _collect_metrics(ELASTICSEARCH_URL, 3)
        self.assertEqual(expected_message, actual_message)

    @mock.patch('requests.get', mock.Mock(
        side_effect=lambda url, auth, timeout, verify: get_unavailable_health_response()))
    def test_metrics_when_elasticsearch_ingress_is_unavailable(self):
        expected_message = 'elasticsearch_cluster_health status_code=10,health_code=-1,total_number_of_nodes=3,' \
                           'number_of_nodes=0i'
        actual_message = _collect_metrics(ELASTICSEARCH_URL, 3)
        self.assertEqual(expected_message, actual_message)

    @mock.patch('health_metric._get_health_data', mock.Mock(
        side_effect=lambda url, parameter: 'green 3'))
    def test_metrics_when_all_nodes_are_active_and_health_is_green(self):
        expected_message = 'elasticsearch_cluster_health status_code=0,health_code=0,total_number_of_nodes=3'
        actual_message = _collect_metrics(ELASTICSEARCH_URL, 3)
        self.assertEqual(expected_message, actual_message)

    @mock.patch('health_metric._get_health_data', mock.Mock(
        side_effect=lambda url, parameter: 'yellow 3'))
    def test_metrics_when_all_nodes_are_active_and_health_is_yellow(self):
        expected_message = 'elasticsearch_cluster_health status_code=6,health_code=6,total_number_of_nodes=3'
        actual_message = _collect_metrics(ELASTICSEARCH_URL, 3)
        self.assertEqual(expected_message, actual_message)

    @mock.patch('health_metric._get_health_data', mock.Mock(
        side_effect=lambda url, parameter: 'red 3'))
    def test_metrics_when_all_nodes_are_active_and_health_is_red(self):
        expected_message = 'elasticsearch_cluster_health status_code=10,health_code=10,total_number_of_nodes=3'
        actual_message = _collect_metrics(ELASTICSEARCH_URL, 3)
        self.assertEqual(expected_message, actual_message)

    @mock.patch('health_metric._get_health_data', mock.Mock(
        side_effect=lambda url, parameter: 'green 2'))
    def test_metrics_when_not_all_nodes_are_active_and_health_is_green(self):
        expected_message = 'elasticsearch_cluster_health status_code=6,health_code=0,total_number_of_nodes=3'
        actual_message = _collect_metrics(ELASTICSEARCH_URL, 3)
        self.assertEqual(expected_message, actual_message)

    @mock.patch('health_metric._get_health_data', mock.Mock(
        side_effect=lambda url, parameter: 'yellow 2'))
    def test_metrics_when_not_all_nodes_are_active_and_health_is_yellow(self):
        expected_message = 'elasticsearch_cluster_health status_code=6,health_code=6,total_number_of_nodes=3'
        actual_message = _collect_metrics(ELASTICSEARCH_URL, 3)
        self.assertEqual(expected_message, actual_message)


def get_unavailable_health_response():
    response = Response()
    response.status_code = 503
    response._content = '<html>\r\n<head><title>503 Service Temporarily Unavailable</title></head>\r\n<body>\r\n' \
                        '<center><h1>503 Service Temporarily Unavailable</h1></center>\r\n<hr><center>nginx</center>' \
                        '\r\n</body>\r\n</html>\r\n'
    return response


if __name__ == '__main__':
    unittest.main()
