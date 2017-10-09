#!/bin/bash

# examples url  
# http://releases.galeracluster.com/mysql-wsrep-5.6.36-25.20/binary/mysql-wsrep-5.6.36-25.20-linux-x86_64.tar.gz  
# http://releases.galeracluster.com/mysql-wsrep-5.6/binary/mysql-wsrep-5.6.36-25.20-linux-x86_64.tar.gz

urldir=http://releases.galeracluster.com/mysql-wsrep-__version/binary

mkdir -p  __workdir/../_depot/w-tar/__version

set -e

(
function cleanup {
  [ -z "$wgetpid" ] || kill "$wgetpid" 2>/dev/null
}

trap cleanup exit


cd __workdir/../_depot/w-tar/__version
res=0
if [ ! -f mysql-wsrep-__version*-linux-x86_64.tar.gz  ] ; then 
  echo downloading "$urldir/mysql-wsrep-__version*-linux-x86_64.tar.gz"
  wget -q -r -np -nd -A "mysql-wsrep-__version*-linux-x86_64.tar.gz" -nc "$urldir/" &
  wgetpid=$!
  while kill -0 $wgetpid 2>/dev/null ; do
    sleep 10
    echo -n .
  done
  wait $wgetpid
  res=$?

  wgetpid=""
fi

[ $res == 0 ] || exit $res

if [ -f mysql-wsrep-__version*-linux-x86_64.tar.gz ] ; then 
  [ -x bin/mysqld ] || tar -zxf mysql-wsrep-__version*-linux-x86_64.tar.gz --strip 1
fi

)

