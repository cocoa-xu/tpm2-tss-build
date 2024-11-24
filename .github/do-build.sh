#!/bin/sh

set -eux

VERSION=$1
ARCH=$2
ABI=$3
TRIPLET="${ARCH}-linux-${ABI}"

export DEBIAN_FRONTEND=noninteractive

case $TRIPLET in
  *-linux-gnu* )
    apt-get -y update
    apt-get -y install \
      autoconf-archive \
      libcmocka0 \
      libcmocka-dev \
      procps \
      iproute2 \
      build-essential \
      git \
      pkg-config \
      gcc \
      libtool \
      automake \
      libssl-dev \
      uthash-dev \
      autoconf \
      doxygen \
      libjson-c-dev \
      libini-config-dev \
      libcurl4-openssl-dev \
      uuid-dev \
      libltdl-dev \
      libusb-1.0-0-dev \
      libftdi-dev
    ;;
  * )
    echo "Unknown triplet: ${TRIPLET}"
    exit 1
    ;;
esac

cd /work
export SRC_FILENAME="tpm2-tss-${VERSION}.tar.gz"

export ROOTDIR="$(pwd)"
export SRC_DIR="${ROOTDIR}/tpm2-tss-${VERSION}"
export DESTDIR="${ROOTDIR}/artifact/tpm2-tss"
export ARCHIVE_FILENAME="tpm2-tss-${TRIPLET}.tar.gz"

rm -rf "${SRC_DIR}"
mkdir -p "${SRC_DIR}"
rm -rf "${DESTDIR}"
mkdir -p "${DESTDIR}"

tar -xzf "${SRC_FILENAME}"
cd "${SRC_DIR}"

if [ -f "./bootstrap" ]; then
  ./bootstrap
fi
./configure
make -j$(nproc)
make DESTDIR="${DESTDIR}" install

# Make .pc files relocatable
cd "${DESTDIR}/usr/local/lib/pkgconfig"
sed -i 's|^prefix=.*|prefix=${pcfiledir}/../..|' *.pc

tar -C "${DESTDIR}/usr/local" -czf "${ROOTDIR}/artifact/${ARCHIVE_FILENAME}" .
cd "${ROOTDIR}/artifact"
shasum -a 512 "${ARCHIVE_FILENAME}" | tee "${ARCHIVE_FILENAME}.sha512"
