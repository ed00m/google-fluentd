#!/bin/bash
# Usage:
# // To build and publish the Docker image to a container registry.
# $ CONTAINER_REGISTRY=<container_registry> ./release.sh
# // To build and publish the Docker image to a container registry with a certain suffix.
# $ CONTAINER_REGISTRY=<container_registry> DOCKER_IMAGE_VERSION_SUFFIX=-pre-1 ./release.sh
set -ex

if [[ -z "${CONTAINER_REGISTRY}" ]]; then
  echo "Please provide a CONTAINER_REGISTRY environment variable.";
  exit 1;
fi

DOCKER_IMAGE_NAME="stackdriver-logging-agent"

# Set version variables. See docker/VERSION file for details.
source VERSION

DOCKER_IMAGE_VERSION="${DOCKERFILE_VERSION}-${GOOGLE_FLUENTD_VERSION}"

# If not on the master branch, append the branch name as part of the image version to avoid conflicts.
GIT_BRANCH=`git status | grep "On branch" | sed 's/On branch //g'`
if [ "${GIT_BRANCH}" != "master" ]; then
  DOCKER_IMAGE_VERSION="${DOCKER_IMAGE_VERSION}-${GIT_BRANCH}";
fi

DOCKER_IMAGE_VERSION="${DOCKER_IMAGE_VERSION}${DOCKER_IMAGE_VERSION_SUFFIX:-}"

echo "Building ${DOCKER_IMAGE_VERSION}."
docker build --no-cache -t "${CONTAINER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}" .
echo "Releasing ${DOCKER_IMAGE_VERSION} to the container registry ${CONTAINER_REGISTRY}."
docker push "${CONTAINER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}"
