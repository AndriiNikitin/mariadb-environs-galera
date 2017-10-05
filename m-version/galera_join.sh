#!/bin/bash

[ ! -z "$1" ] || { echo "Expected name of donor environ as first parameter; got ($1)";  exit 2; }
[ -d ${1}* ] || { echo "Cannot find environ ($1)";  exit 2; }

set -e

cluster_name=$($1*/galera_read_cluster_name.sh)
join_ip=$($1*/galera_read_ip.sh)

touch __workdir/mysqldextra.cnf

echo '[mysqld]' >> __workdir/mysqldextra.cnf

if ! grep -q wsrep_provider= __workdir/mysqldextra.cnf ; then

if [ -f /usr/lib/galera/libgalera_smm.so ] ; then
  echo wsrep_provider=/usr/lib/galera/libgalera_smm.so >> __workdir/mysqldextra.cnf
elif [ -f /usr/lib64/galera/libgalera_smm.so ] ; then
  echo wsrep_provider=/usr/lib64/galera/libgalera_smm.so >> __workdir/mysqldextra.cnf
elif [ -f __workdir/../_depot/m-tar/__version/lib/libgalera_smm.so ] ; then
  echo wsrep_provider=__workdir/../_depot/m-tar/__version/lib/libgalera_smm.so >> __workdir/mysqldextra.cnf
else
  >&2 echo "Cannot find libgalera"
  exit 2
fi

cat >> __workdir/mysqldextra.cnf <<EOL
binlog_format=ROW
default-storage-engine=innodb
innodb_autoinc_lock_mode=2
bind-address=0.0.0.0

wsrep_on=ON
wsrep_sst_method=mysqldump
EOL

fi

h=$(__workdir/galera_ip.sh)
p=$(__workdir/galera_port.sh)

echo wsrep_cluster_name=$cluster_name  >> __workdir/mysqldextra.cnf
echo wsrep_node_address=$h:$p >> __workdir/mysqldextra.cnf
echo wsrep_node_name=${h}_$p >> __workdir/mysqldextra.cnf
echo wsrep_cluster_address="gcomm://$join_ip" >> __workdir/mysqldextra.cnf

shift

[ ! -z "$1" ] && for o in $@ ; do
  echo $o >> __workdir/mysqldextra.cnf
done

# let mysqld find mysqldump
export PATH=$PATH:__workdir/../_depot/m-tar/__version/bin

__workdir/startup.sh
