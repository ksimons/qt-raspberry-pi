qt-raspberry-pi
===============

This is a set of scripts for bulding Qt (specifically qtbase, qtjsbackend and qtdeclarative) against the official Raspbian distribution coming from Raspberry Pi. It is by no means the only way to get Qt on the Raspberry Pi, but it is an easy way if you want to use the reference distribution. It has been tested against the "wheezy" version only. This is a "works for me" solution and is provided with absolutely no guarantee.

Setting up a sysroot
--------------------
1. Download a zipped Raspbian image from http://www.raspberrypi.org/downloads
2. Unzip the image
3. Run the setup-sysroot.sh script, passing the .img file as the only argument:

        ./setup-sysroot.sh ~/Downloads/2012-08-16-wheezy-raspbian.img

Do not run the script with sudo. The script itself will invoke sudo as necessary. The script requires the 'symlinks' command (which comes from the package of the same name), so install this before running the script if you don't already have it.

Building Qt
-----------
1. Fetch the Qt and toolchain submodules

        git submodule update --init

2. Run the build-qt.sh script to compile Qt. The script takes the path to the sysroot and two optional arguments:

        -j N - specifies how many concurrent build jobs to run (passed to 'make')
        -s IP-ADDRESS-OF-RASPBERRY-PI - the IP address of the Raspberry Pi to which to rsync Qt to after compiling.

    Note: you must have rsync installed on the Raspberry Pi before rsync-ing.

    For example, to compile with 8 jobs and sync to a Raspberry Pi at IP 192.168.1.2 do the following:

        build-qt.sh -j 8 -s 192.168.1.2 /mnt/2012-08-16-wheezy-raspbian

3. If you didn't pass the -s option in step 2, you need to copy Qt to the device. rsync works well for this (must be installed on the device first):

        rsync -av --exclude=include /mnt/2012-08-16-wheezy-raspbian/opt/qt pi@192.168.1.2:/opt

chroot-ing into the sysroot
---------------------------
If you're feeling ambitious and want to install additional packages in the sysroot before building Qt, it's quite easily done via chroot:

    sudo apt-get -y install qemu qemu-user qemu-user-static binfmt-support
    sudo cp /usr/bin/qemu-arm-static /mnt/2012-08-16-wheezy-raspbian/usr/bin
    sudo chroot /mnt/2012-08-16-wheezy-raspbian

You may then use 'apt-get' as normal and install any packages you require.