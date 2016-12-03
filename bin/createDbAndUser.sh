#!/bin/bash

MYSQL=/usr/bin/mysql

die() {
    echo $1;
    exit 1;
}

if [ $# -lt 3 ]; then 
    die "usage "$0" dbname dbuser pass"
fi
DBNAME=$1
DBUSER=$2
DBPASS=$3


OLDDIR=$(pwd)
WDIR=$(dirname $0)

cd $WDIR

echo "SHOW DATABASES" | $MYSQLROOTCMD
echo "Please enter root db password: "
read -s MYSQLROOTPASS
echo $MYSQLROOTPASS 

MYSQLISOCMD="$MYSQL -u$DBUSER  -p$DBPASS"
MYSQLROOTCMD="$MYSQL -uroot  -p$MYSQLROOTPASS"

echo $MYSQLISOCMD

if echo "show databases" | $MYSQLROOTCMD | grep "^$DBNAME$" 2>&1 > /dev/null 
then
    echo "db exists.. no action"
   else
    MYSQLROOTCMD="$MYSQL -uroot  -p$MYSQLROOTPASS"

    echo "creating database $DBNAME..."
    echo "CREATE DATABASE IF NOT EXISTS $DBNAME" | $MYSQLROOTCMD || die "unable to create db";
    echo "DB creation done"
    echo "grating privileges for $DBUSER"
    echo "grant all on $DBNAME.* to $DBUSER@'localhost' identified by \"$DBPASS\"" | $MYSQLROOTCMD || die "unable to grand privs for user $DBUSER" 
    echo "FLUSH PRIVILEGES" | $MYSQL -uroot -p"$MYSQLROOTPASS" || die "unable to flush privs"
    echo "done granting privileges for $DBUSER"
fi
exit;

