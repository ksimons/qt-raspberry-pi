#! /bin/bash

function usage
{
  echo "Usage: `basename $0` SYSROOT IP_ADDRESS"
  echo "Install Qt using the specified:"
  echo "SYSROOT		The path to the mounted Raspbian image"
  echo "IP_ADDRESS      The IP address of the device to which to install Qt"
  exit 1
}

if [[ $# -ne 2 ]]; then
  usage
fi

sysroot=$1
sync_ip=$2

echo "Syncing Qt to $sync_ip"
rsync -av --exclude=include $sysroot/opt/qt pi@$sync_ip:/opt

