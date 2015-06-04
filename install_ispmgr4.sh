#!/bin/sh

arch=`uname -m`
OSver=`uname -r | sed -E 's/^([0-9]+).*$/\1/'`

if [ ! -f "`which sqlite3`" ] || [ ! -f "`which svn`" ]; then
    echo "Please install:"
    echo ""
    echo " sqlite3: pkg install sqlite3"
    echo " subversion: pkg install subversion"
    echo ""
    exit
fi

if [ ! -d "/usr/local/lib/compat" ] && [ $OSver -eq "10" ]; then
    echo "Please install:"
    echo ""
    echo " compat9x-amd64: pkg install compat9x-amd64"
    echo ""
    exit
fi

if [ $# -eq 0 ]; then
    echo "Usage:"
    echo " `basename "$0"` Pro"
    echo " `basename "$0"` Lite 192.168.1.100"
    echo ""
    exit
fi

if [ ! -z "$2" ]; then
    if [ -z "`ifconfig | grep $2`" ]; then
        echo "Wrong IP address"
        exit
    fi
fi

if [ $1 != "Pro" ] && [ $1 != "Lite" ]; then
    echo "Wrong ISPmanager version"
    exit
fi

if [ ! -f "/usr/ports/Makefile" ]; then
    echo "Downloading ports collection..."
    svn --quiet co svn://svn.freebsd.org/ports/head/ /usr/ports
fi

cd /usr/ports
make fetchindex

if [ $OSver -eq "10" ]; then
    cp /usr/ports/INDEX-10 /usr/ports/INDEX-9
fi

echo "Downloading ISPmanager..."
fetch -o /tmp/install.tgz -q "http://download.ispsystem.com/FreeBSD-9.3/$arch/ISPmanager-$1/install.tgz"
mkdir /usr/local/ispmgr
cd /usr/local/ispmgr
tar -xzpf /tmp/install.tgz
sh sbin/ISPmanager-install.sh download.ispsystem.com $2
