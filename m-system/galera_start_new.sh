#!/bin/bash

echo '[mysqld]' >> __workdir/mysqldextra.cnf

if ! grep -q wsrep_provider= __workdir/mysqldextra.cnf 2>/dev/null ; then

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

h=$(__workdir/galera_ip.sh)
p=$(__workdir/galera_port.sh)

echo wsrep_node_address=$h:$p >> __workdir/mysqldextra.cnf
echo wsrep_node_name=${h}_$p >> __workdir/mysqldextra.cnf
echo wsrep_cluster_address=gcomm://$h:$p >> __workdir/mysqldextra.cnf
echo wsrep_cluster_name=${h}_$p >> __workdir/mysqldextra.cnf

fi

[ ! -z "$1" ] && for o in $@ ; do
  echo $o >> __workdir/mysqldextra.cnf
done


__workdir/startup.sh --wsrep-new-cluster
