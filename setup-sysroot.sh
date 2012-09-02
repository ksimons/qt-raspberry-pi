#! /bin/bash

function usage
{
  echo "Usage: `basename $0` IMG_FILE"
  echo "Set up the specified image file as a sysroot for cross compilation"
  exit 1
}

function fix_symlinks
{
  # fix broken symlinks
  original_IFS=$IFS
  IFS=`echo -en "\n\b"`
  for symlink in `symlinks -r $1 | grep dangling`; do
    link=`echo $symlink | sed -r 's/dangling:\s(.*)\s->\s.*/\1/'`
    target=`echo $symlink | sed -r 's/dangling:\s.*\s->\s(.*)/\1/'`

    # remove the broken link and replace it with an absolute one
    # which will be made relative shortly
    if [[ -e $2/$target ]]; then
      sudo rm $link
      sudo ln -s $2/$target $link
    fi
  done
  IFS=$original_IFS

  # turn the absolute links into relative ones
  sudo symlinks -rc $1 > /dev/null 2>&1
}

if [[ $EUID -eq 0 ]]; then
  echo "Do not run this script as root."
  echo "The script will invoke sudo as needed."
  exit 1
fi

if [[ $# -ne 1 ]]; then
  usage
fi

image_file=$1

if [[ "$image_file" =~ \.img$ ]]; then
  image_name=`basename $image_file .img`
  sysroot_path="/mnt/$image_name"
  if [[ ! -d $sysroot_path ]]; then
    sudo mkdir $sysroot_path
  fi

  # only go through mounting process if it's not already
  # mounted
  cat /proc/mounts | grep $sysroot_path > /dev/null
  if [[ $? -ne 0 ]]; then
    echo "Mounting image"
    # NOTE: not sure if this changes with different images
    fdisk_out=`fdisk -l -C 8192 $image_file | grep Linux`
    if [[ $? -ne 0 ]]; then
      echo "Unable to read partition table. Exiting."
      exit 1
    fi

    offset=`echo $fdisk_out | sed -r 's/.*\s([[:digit:]]+)\s[[:digit:]]+\s[[:digit:]]+\s[[:digit:]]+\sLinux/\1/'`
    sudo mount -o loop,offset=$((512*$offset)) $image_file $sysroot_path > /dev/null 2>&1

    if [[ $? -ne 0 ]]; then
      echo "Unable to mount image as loopback. Exiting."
      exit 1
    fi

    echo "Done"
  fi
    
  echo "Fixing up symlinks..."
  # fix up dangling links
  fix_symlinks $sysroot_path/lib $sysroot_path
  fix_symlinks $sysroot_path/lib/arm-linux-gnueabihf $sysroot_path
  fix_symlinks $sysroot_path/usr/lib $sysroot_path
  fix_symlinks $sysroot_path/usr/lib/arm-linux-gnueabihf $sysroot_path
  fix_symlinks $sysroot_path/usr/include $sysroot_path
  echo "Done"
else
  echo "Please provide a valid .img file"
  usage
fi

