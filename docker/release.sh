#!/bin/bash
# Usage:
# // To build and publish the Docker image to the internal container registry.
# $ PUBLIC_DESTINATION=internal bash release.sh
# // To publish the Docker image to the public container registry.
# $ PUBLIC_DESTINATION=public bash release.sh
set -ex

INTERNAL_CONTAINER_REGISTRY='us.gcr.io/container-monitoring-storage/stackdriver-logging-agent'
PUBLIC_CONTAINER_REGISTRY='gcr.io/stackdriver-agents/stackdriver-logging-agent'

docker_file_version=`grep DOCKER_FILE_VERSION VERSION | sed 's/DOCKER_FILE_VERSION=//g'`
google_fluentd_version=`grep GOOGLE_FLUENTD_VERSION VERSION | sed 's/GOOGLE_FLUENTD_VERSION=//g'`
# TODO(qingling128): Remove this suffix when kubernetes-branch is deprecated.
image_suffix=""
docker_image_version="${docker_file_version}-${google_fluentd_version}${image_suffix}"

if [[ -z "${PUBLIC_DESTINATION}" ]]; then
  echo "Please provide a PUBLIC_DESTINATION environment variable.";
  exit 1;
fi

if [ "${PUBLIC_DESTINATION}" == "internal" ]; then
  echo "Building ${DOCKER_IMAGE_VERSION}.";
  docker build -t "${INTERNAL_CONTAINER_REGISTRY}:${docker_image_version}" .
  echo "Releasing ${DOCKER_IMAGE_VERSION} to the internal container registry.";
  docker push "${INTERNAL_CONTAINER_REGISTRY}:${docker_image_version}";
elif [ "${PUBLIC_DESTINATION}" == "public" ]; then
  echo "Releasing ${DOCKER_IMAGE_VERSION} to the public container registry.";
  docker pull "${INTERNAL_CONTAINER_REGISTRY}:${docker_image_version}";
  docker tag "${INTERNAL_CONTAINER_REGISTRY}:${docker_image_version}" "${PUBLIC_CONTAINER_REGISTRY}:${docker_image_version}";
  docker push "${PUBLIC_CONTAINER_REGISTRY}:${docker_image_version}";
else
  echo "Unknown PUBLIC_DESTINATION environment variable ${PUBLIC_DESTINATION}.";
  exit 1;
fi

