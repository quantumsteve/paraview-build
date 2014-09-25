#!/bin/bash -ex
##############################################################################
# Script for creating a ParaView kit on OSX
##############################################################################

##############################################################################
# Print some things for cross-checking
##############################################################################
cmake --version

if [[ ${JOB_NAME} == *10.9* ]]; then
  OSX_VERSION=10.9
else
  OSX_VERSION=10.8
fi

echo "OSX VERSION = ${OSX_VERSION}"

# Get ParaView superbuild

git clone -b v4.2.0 git://paraview.org/ParaViewSuperbuild.git

# Create build directory

[ -d ${WORKSPACE}/build ] || mkdir ${WORKSPACE}/build
cd ${WORKSPACE}/build

# Setup and build

MAIN_SETUP="-DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_VERSION}"
PACKAGES="-DBUILD_TESTING=OFF -DENABLE_matplotlib=ON -DENABLE_paraview=ON -DENABLE_python=ON -DENABLE_qt=ON"
PVOPTS="-DParaView_FROM_GIT=OFF"
USE_SYSTEM="-DUSE_SYSTEM_matplotlib=ON -DUSE_SYSTEM_python=ON -DUSE_SYSTEM_qt=ON"

cmake ${MAIN_SETUP} ${PACKAGES} ${PVOPTS} ${USE_SYSTEM} ${WORKSPACE}/ParaViewSuperBuild

make -j ${BUILD_THREADS}

cpack -G DragNDrop
