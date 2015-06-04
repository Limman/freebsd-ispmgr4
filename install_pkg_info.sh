#!/bin/sh

if [ -d "/var/db/pkgdb" ]; then
    echo "It is already installed!"
    exit
fi

mv /var/db/pkg /var/db/pkgdb
mkdir /var/db/pkg

if [ ! -f "/usr/local/etc/pkg.conf" ]; then
    cp /usr/local/etc/pkg.conf.sample /usr/local/etc/pkg.conf
fi

sed -i '' 's/\#PKG_DBDIR/PKG_DBDIR/g' /usr/local/etc/pkg.conf
sed -i '' 's/\/var\/db\/pkg/\/var\/db\/pkgdb/g' /usr/local/etc/pkg.conf

if [ -f "/usr/sbin/pkg_info" ]; then
    mv /usr/sbin/pkg_info /usr/sbin/pkg_info.orig
fi

fetch -o /usr/sbin/pkg_info -q --no-verify-peer "https://github.com/Limman/freebsd-ispmgr4/raw/master/pkg_info"
chmod 555 /usr/sbin/pkg_info
echo "Done. Run pkg_info to build old-style packages database for ISPmanager 4"
