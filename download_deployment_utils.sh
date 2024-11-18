#!/usr/bin/env bash

deployment_utils_version="v.0.0.14_20191106-031913"
deployment_utils_url="https://artifactorycn.netcracker.com/nc.sandbox.files/product/prod.platform.elasticstack/deployment-utils/${deployment_utils_version}/infrastructure1.0/deployment-utils-artifacts.zip"

wget \
  --no-check-certificate \
  -nv \
  -O "openshift/deploy/deployment_utils.zip" \
  ${deployment_utils_url}

mkdir openshift/deploy/deployment_utils

unzip -oq openshift/deploy/deployment_utils.zip -d openshift/deploy/deployment_utils

rm openshift/deploy/deployment_utils.zip