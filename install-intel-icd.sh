#! /bin/bash

set -e
set -x

# When modifying this file: be mindful that it is also being used
# in Loopy's Github CI.

mkdir -p /etc/OpenCL/vendors
rm -f /etc/OpenCL/vendors/intel*oclcpuexp*.icd

cd /opt

# https://github.com/intel/llvm/releases/tag/oclcpuexp-2019.8.7.0.0725_rel
VERSION=oclcpuexp-2019.8.7.0.0725_rel
RELEASE="$VERSION"
TBB_VERSION=""

# https://github.com/intel/llvm/releases/tag/2022-WW13
# still buggy, e.g. https://github.com/intel/llvm/issues/2038
# VERSION=oclcpuexp-2022.13.3.0.16_rel
# RELEASE="2022-WW13"
# TBB_VERSION=2021.5.0

# https://github.com/intel/llvm/releases/tag/2021-09
# buggy, e.g. https://github.com/intel/llvm/issues/2038
# RELEASE=2021-09
# VERSION=oclcpuexp-2021.12.9.0.24_rel
# TBB_VERSION=2021.5.0

OCLPATH="/opt/intel-$VERSION"

if test -d "$OCLPATH" ; then
	rm -Rf "$OCLPATH"
fi

curl -L -O "https://github.com/intel/llvm/releases/download/$RELEASE/$VERSION.tar.gz"
mkdir -p "$OCLPATH"
tar xz -C "$OCLPATH" -f $VERSION.tar.gz
chmod go+rX -R "$OCLPATH"

if test "$TBB_VERSION"; then 
  TBB_FILENAME="oneapi-tbb-$TBB_VERSION-lin.tgz"
  curl -L -O "https://github.com/oneapi-src/oneTBB/releases/download/v$TBB_VERSION/oneapi-tbb-$TBB_VERSION-lin.tgz"
  tar x --strip-components=4 -C $OCLPATH/x64  -f "$TBB_FILENAME" oneapi-tbb-$TBB_VERSION/lib/intel64/gcc4.8/
  rm "$TBB_FILENAME"
fi

echo "$OCLPATH/x64/libintelocl.so" > /etc/OpenCL/vendors/intel-$VERSION.icd
rm -Rf $OCLPATH/x64/libOpenCL.so*

echo "export LD_LIBRARY_PATH=$OCLPATH/x64:"'$LD_LIBRARY_PATH' > /opt/enable-intel-cl.sh

rm "$VERSION.tar.gz"

# vim: sw=2
