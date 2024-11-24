#!/bin/sh

set -eux

VERSION=$1
ARCH=$2
ABI=$3
IMAGE_NAME=$4
DOCKER_PLATFORM=$5

if [ ! -z "${DOCKER_PLATFORM}" ]; then
  sudo docker run --privileged --network=host --rm -v $(pwd):/work --platform="${DOCKER_PLATFORM}" "${IMAGE_NAME}" \
    sh -c "chmod a+x /work/do-build.sh && /work/do-build.sh ${VERSION} ${ARCH} ${ABI}"
else
  sudo docker run --privileged --network=host --rm -v $(pwd):/work "${IMAGE_NAME}" \
    sh -c "chmod a+x /work/do-build.sh && /work/do-build.sh ${VERSION} ${ARCH} ${ABI}"
fi
