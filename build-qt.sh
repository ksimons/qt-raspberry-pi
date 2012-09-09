#! /bin/bash

function usage
{
  echo "Usage: `basename $0`[OPTIONS] SYSROOT"
  echo "Build Qt and optionally sync it to a device"
  echo "Options:"
  echo "-j N		Specifies the number of jobs to run simultaneously"
  echo "-s IP_ADDRESS	After compiling, sync the binaries to the specified device"
  exit 1
}

if [[ $EUID -eq 0 ]]; then
  echo "Do not run this script as root."
  echo "The script will invoke sudo as needed."
  exit 1
fi

sysroot=""
make_jobs=""
sync_ip=""

while [[ $# -ne 0 ]]
do
  case "$1" in
  -j) make_jobs="$2"
      shift 2
      ;;
  -s) sync_ip="$2"
      shift 2
      ;;
  *)  if [[ $sysroot != "" ]]; then usage; fi
      sysroot="$1"
      shift 
      ;;
  esac
done

if [[ $sysroot = "" ]]; then
  usage
fi

if [[ "$make_jobs" != "" ]] && [[ ! $make_jobs =~ ^[0-9]+$ ]]; then
  echo "Invalid number of jobs: $make_jobs"
  usage
fi

if [[ "$make_jobs" != "" ]]; then
  make_jobs="-j $make_jobs"
fi

# TODO: some rough checks of sysroot validity

basedir=$PWD
qtdir=/opt/qt/5.0.0

cd $basedir/qtbase

# configure qtbase
if [[ ! -f "./config.status" ]]; then
  echo "Configuring qtbase..."
  ./configure -opensource -confirm-license -v -optimized-qmake \
              -release -make libs \
              -opengl es2 -device linux-rasp-pi-g++ \
              -reduce-relocations -reduce-exports \
              -device-option DISTRO="wheezy" \
              -device-option CROSS_COMPILE=$basedir/rasp-pi-tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin/arm-linux-gnueabihf- \
              -sysroot $sysroot \
              -nomake tests -nomake examples \
              -prefix $qtdir \
              -no-pch \
              -R $qtdir/lib
fi

echo "Compiling qtbase..."
make $make_jobs
sudo make install

echo "Compiling qtjsbackend..."
cd $basedir/qtjsbackend
$qtdir/bin/qmake -r
make $make_jobs
sudo make install

echo "Compiling qtdeclarative..."
cd $basedir/qtdeclarative
$qtdir/bin/qmake -r
make $make_jobs
sudo make install
cd tools
make $make_jobs
sudo make install

cd $basedir

if [[ "$sync_ip" != "" ]]; then
  echo "Syncing Qt to $sync_ip"
  rsync -av --exclude=include $sysroot/opt/qt pi@$sync_ip:/opt
fi

echo "Done"
