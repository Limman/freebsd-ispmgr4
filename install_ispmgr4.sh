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

if [ $OSver -eq "10" ] && [ ! -f "/usr/ports/INDEX-9" ]; then
    ln -s /usr/ports/INDEX-10 /usr/ports/INDEX-9
fi

echo "Installing new pkg_info..."
if [ ! -d "/var/db/pkgdb" ]; then  
    mv /var/db/pkg /var/db/pkgdb
    mkdir /var/db/pkg

    if [ ! -f "/usr/local/etc/pkg.conf" ]; then
        cp /usr/local/etc/pkg.conf.sample /usr/local/etc/pkg.conf
    fi

    sed -i '' 's/\#PKG_DBDIR/PKG_DBDIR/g' /usr/local/etc/pkg.conf
    sed -i '' 's/\"\/var\/db\/pkg\"/\"\/var\/db\/pkgdb\"/g' /usr/local/etc/pkg.conf

    if [ -f "/usr/sbin/pkg_info" ]; then
        mv /usr/sbin/pkg_info /usr/sbin/pkg_info.orig
    fi

    fetch -o /usr/sbin/pkg_info -q --no-verify-peer "https://github.com/Limman/freebsd-ispmgr4/raw/master/pkg_info"
    chmod 555 /usr/sbin/pkg_info
    echo "Building old packages database..."
    /usr/sbin/pkg_info update
else
    echo "New pkg_info is already installed!"    
fi

echo "Downloading ISPmanager..."
fetch -o /tmp/install.tgz -q "http://download.ispsystem.com/FreeBSD-9.3/$arch/ISPmanager-$1/install.tgz"
mkdir /usr/local/ispmgr
cd /usr/local/ispmgr
tar -xzpf /tmp/install.tgz
sh sbin/ISPmanager-install.sh download.ispsystem.com $2
