#!/bin/bash
# Usage:
# // To build and publish the Docker image to the internal container registry.
# $ DESTINATION=internal INTERNAL_CONTAINER_REGISTRY=<internal_registry> ./release.sh
# // To publish the Docker image to the public container registry.
# $ DESTINATION=public ./release.sh
set -ex

PUBLIC_CONTAINER_REGISTRY='gcr.io/stackdriver-agents/stackdriver-logging-agent'

source VERSION
# TODO(qingling128): Remove this suffix when kubernetes-branch is deprecated.
IMAGE_SUFFIX=""
DOCKER_IMAGE_VERSION="${DOCKERFILE_VERSION}-${GOOGLE_FLUENTD_VERSION}${IMAGE_SUFFIX}"
DESTINATION=${DESTINATION:-internal}

if [[ -z "${INTERNAL_CONTAINER_REGISTRY}" ]]; then
  echo "Please provide a INTERNAL_CONTAINER_REGISTRY environment variable.";
  exit 1;
fi

if [ "${DESTINATION}" == "internal" ]; then
  echo "Building ${DOCKER_IMAGE_VERSION}.";
  docker build --no-cache -t "${INTERNAL_CONTAINER_REGISTRY}:${DOCKER_IMAGE_VERSION}" .
  echo "Releasing ${DOCKER_IMAGE_VERSION} to the internal container registry.";
  docker push "${INTERNAL_CONTAINER_REGISTRY}:${DOCKER_IMAGE_VERSION}";
elif [ "${DESTINATION}" == "public" ]; then
  echo "Releasing ${DOCKER_IMAGE_VERSION} to the public container registry.";
  docker pull "${INTERNAL_CONTAINER_REGISTRY}:${DOCKER_IMAGE_VERSION}";
  docker tag "${INTERNAL_CONTAINER_REGISTRY}:${DOCKER_IMAGE_VERSION}" "${PUBLIC_CONTAINER_REGISTRY}:${DOCKER_IMAGE_VERSION}";
  docker push "${PUBLIC_CONTAINER_REGISTRY}:${DOCKER_IMAGE_VERSION}";
else
  echo "Unknown DESTINATION environment variable ${DESTINATION}.";
  exit 1;
fi
