#!/bin/bash
# Usage:
# // To build and publish the Docker image to the internal container registry.
# $ DESTINATION=internal INTERNAL_CONTAINER_REGISTRY=<internal_registry> ./release.sh
# // To publish the Docker image to the public container registry.
# $ DESTINATION=public INTERNAL_CONTAINER_REGISTRY=<internal_registry> ./release.sh
set -ex

PUBLIC_CONTAINER_REGISTRY="gcr.io/stackdriver-agents/stackdriver-logging-agent"
DESTINATION="${DESTINATION:-internal}"

# Set versions. See docker/VERSION file for details.
source VERSION

# Decide the Docker image version to be released based on the current Git branch.
GIT_BRANCH=`git status | grep "On branch" | sed 's/On branch //g'`
case "${GIT_BRANCH}" in
  lingshi-version)
    DOCKER_IMAGE_VERSION="${DOCKERFILE_VERSION}-${GOOGLE_FLUENTD_VERSION}";
    ;;
  kubernetes)
    DOCKER_IMAGE_VERSION="${DOCKERFILE_VERSION}-${GOOGLE_FLUENTD_VERSION}-k8s";
    ;;
  *)
    echo "This script should only be used for restricted branches. Exiting.";
    exit 1;
    ;;
esac


if [[ -z "${INTERNAL_CONTAINER_REGISTRY}" ]]; then
  echo "Please provide a INTERNAL_CONTAINER_REGISTRY environment variable.";
  exit 1;
fi

case "${DESTINATION}" in
  internal)
    echo "Building ${DOCKER_IMAGE_VERSION}.";
    docker build --no-cache -t "${INTERNAL_CONTAINER_REGISTRY}:${DOCKER_IMAGE_VERSION}" .;
    echo "Releasing ${DOCKER_IMAGE_VERSION} to the internal container registry.";
    docker push "${INTERNAL_CONTAINER_REGISTRY}:${DOCKER_IMAGE_VERSION}";
    ;;
  public)
    echo "Releasing ${DOCKER_IMAGE_VERSION} to the public container registry.";
    docker pull "${INTERNAL_CONTAINER_REGISTRY}:${DOCKER_IMAGE_VERSION}";
    docker tag "${INTERNAL_CONTAINER_REGISTRY}:${DOCKER_IMAGE_VERSION}" "${PUBLIC_CONTAINER_REGISTRY}:${DOCKER_IMAGE_VERSION}";
    docker push "${PUBLIC_CONTAINER_REGISTRY}:${DOCKER_IMAGE_VERSION}";
    ;;
  *)
    echo "Unknown DESTINATION environment variable ${DESTINATION}.";
    exit 1;
    ;;
esac
