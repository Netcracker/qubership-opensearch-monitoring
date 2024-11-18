#!/usr/bin/env bash

JOB_NAME=deploy-elasticsearch-monitoring
JENKINS_URL=http://openshift-ci.openshift.sdntest.netcracker.com/
LOGIN=admin
PASSWORD=admin

run() {
  echo "=> Running Jenkins job..."
  curl -X POST ${JENKINS_URL}/job/${JOB_NAME}/build \
    --user ${LOGIN}:${PASSWORD} \
    -H "$CRUMB" \
    -F json=@ci_parameters.json
}

push() {
  echo "=> Pushing Jenkins job..."
  curl -XPOST ${JENKINS_URL}/createItem?name=${JOB_NAME} \
    --user ${LOGIN}:${PASSWORD} \
    -H "$CRUMB" \
    -H "Content-Type:text/xml" \
    --data-binary @./../config.xml
}

update() {
  echo "=> Updating Jenkins job..."
  curl -X POST ${JENKINS_URL}/job/${JOB_NAME}/config.xml \
    --user ${LOGIN}:${PASSWORD} \
    -H "$CRUMB" \
    -H "Content-Type:text/xml" \
    --data-binary @./../config.xml
}


if [ -z JOB_NAME ]; then
  echo "Fill JOB_NAME parameter"
  return 1
fi
if [ -z JENKINS_URL ]; then
  echo "Fill JENKINS_URL parameter"
  return 1
fi
if [ -z LOGIN ]; then
  echo "Fill LOGIN parameter"
  return 1
fi
if [ -z PASSWORD ]; then
  echo "Fill PASSWORD parameter"
  return 1
fi

CRUMB=$(
  curl -s ${JENKINS_URL}'/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)'\
    --user ${LOGIN}:${PASSWORD}
)

case $1 in
    run )     run
              ;;
    push )    push
              ;;
    update )  update
              ;;
    * )       return 1
esac

