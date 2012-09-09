#! /bin/bash

function usage
{
  echo "Usage: `basename $0` SYSROOT [PATH_TO_QTBASE]"
  echo "Configure Qt using the specified:"
  echo "SYSROOT		The path to the mounted Raspbian image"
  echo "PATH_TO_QTBASE  The path to qtbase. Defaults to \$PWD/qt/qtbase"
  exit 1
}

if [[ $EUID -eq 0 ]]; then
  echo "Do not run this script as root."
  exit 1
fi

sysroot=""
qtbasedir=""

while [[ $# -ne 0 ]]
do
  if [[ $sysroot = "" ]]; then
    sysroot=$1
    shift
    continue
  fi

  if [[ $qtbasedir = "" ]]; then
    qtbasedir=$1
    shift
    continue
  fi

  usage
done

basedir="$( cd "$( dirname $0 )" && pwd )"

# TODO: some rough checks of sysroot validity
if [[ $sysroot = "" ]]; then
  usage
fi

if [[ $qtbasedir = "" ]]; then
  qtbasedir=$basedir/qt/qtbase
fi

if [[ ! -d $qtbasedir ]]; then
  echo "Invalid path to qtbase"
  usage
fi

qtprefix=/opt/qt/5.0.0

echo "Configuring qtbase..."
cd $qtbasedir
./configure -opensource -confirm-license -v -optimized-qmake \
            -release -make libs \
            -opengl es2 -device linux-rasp-pi-g++ \
            -reduce-relocations -reduce-exports \
            -device-option DISTRO="wheezy" \
            -device-option CROSS_COMPILE=$basedir/rasp-pi-tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin/arm-linux-gnueabihf- \
            -sysroot $sysroot \
            -nomake tests -nomake examples \
            -prefix $qtprefix \
            -no-pch \
            -R $qtprefix/lib

echo "Done"
