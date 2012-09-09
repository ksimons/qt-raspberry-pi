qt-raspberry-pi
===============

This is a set of scripts for bulding Qt against the official Raspbian distribution coming from Raspberry Pi. It is by no means the only way to get Qt on the Raspberry Pi, but it is an easy way if you want to use the reference distribution. It has been tested against the "wheezy" version only. This is a "works for me" solution and is provided with absolutely no guarantee.

Setting up a sysroot
--------------------
1. Download a zipped Raspbian image from http://www.raspberrypi.org/downloads
2. Unzip the image
3. Run the setup-sysroot.sh script, passing the .img file as the only argument:

        ./setup-sysroot.sh ~/Downloads/2012-08-16-wheezy-raspbian.img

Do not run the script with sudo. The script itself will invoke sudo as necessary. The script requires the 'symlinks' command (which comes from the package of the same name), so install this before running the script if you don't already have it.

Building Qt
-----------
1. Fetch the toolchain git submodule:

        git submodule update --init rasp-pi-tools

2. Optionally fetch the Qt submodules. If you have your own copy of Qt checked out from git you may use that, but one which has been tested on the Raspberry Pi is provided as a convenience:

        git submodule update --init qt

3. Run the configure-qt.sh script to configure qtbase. This script takes the path to the sysroot and (optionally) the path to qtbase:

        configure-qt.sh /mnt/2012-08-16-wheezy-raspbian ~/Developtment/qt/qtbase

    If you don't provide a path to qtbase, the script will use the one in ./qt/qtbase

4. Compile qtbase. Simply change to the directory where you have qtbase checked out and:

        make 
        sudo make install

5. Compile other Qt modules. The configure-qt.sh script sets up Qt to be installed to /opt/qt/5.0.0, so to build other modules, change into their code directories and:

        /opt/qt/5.0.0/bin/qmake
        make
        sudo make install

Installing Qt to the Raspberry Pi
---------------------------------
1. Install rsync on the Raspberry Pi (replace 'raspi' with the address of your device:

        ssh pi@raspi "sudo apt-get install rsync && exit"

2. Run the install-qt.sh script specifying the path to the sysroot and the address of the device

        install-qt.sh /mnt/2012-08-16-wheezy-raspbian raspi

chroot-ing into the sysroot
---------------------------
If you're feeling ambitious and want to install additional packages in the sysroot before building Qt, it's quite easily done via chroot:

    sudo apt-get -y install qemu qemu-user qemu-user-static binfmt-support
    sudo cp /usr/bin/qemu-arm-static /mnt/2012-08-16-wheezy-raspbian/usr/bin
    sudo chroot /mnt/2012-08-16-wheezy-raspbian

You may then use 'apt-get' as normal and install any packages you require.
