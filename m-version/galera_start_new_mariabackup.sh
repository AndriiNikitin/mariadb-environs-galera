#!/bin/bash

if [ -f /usr/lib/galera/libgalera_smm.so ] ; then
  echo wsrep_provider=/usr/lib/galera/libgalera_smm.so >> __workdir/my.cnf
elif [ -f /usr/lib64/galera/libgalera_smm.so ] ; then
  echo wsrep_provider=/usr/lib64/galera/libgalera_smm.so >> __workdir/my.cnf
elif [ -f __workdir/../_depot/m-tar/__version/lib/libgalera_smm.so ] ; then
  echo wsrep_provider=__workdir/../_depot/m-tar/__version/lib/libgalera_smm.so >> __workdir/my.cnf
else
  >&2 echo "Cannot find libgalera"
  exit 2
fi


cat >> __workdir/my.cnf <<EOL
binlog_format=ROW
default-storage-engine=innodb
innodb_autoinc_lock_mode=2
bind-address=0.0.0.0

wsrep_on=ON
wsrep_sst_method=xmariabackup
EOL

h=$(hostname -i)

echo wsrep_node_address=$h >> __workdir/my.cnf
echo wsrep_node_name=$h >> __workdir/my.cnf
echo wsrep_cluster_address=gcomm://$h >> __workdir/my.cnf
echo wsrep_cluster_name=$h >> __workdir/my.cnf


# this to let galera find mysqldump and mysql
export PATH=__workdir/../_depot/m-tar/__version/bin:$PATH

__workdir/../_depot/m-tar/__version/bin/mysqld_safe --defaults-file=__workdir/my.cnf --loose-syslog=0 --user=$(whoami) --wsrep-new-cluster & 
__workdir/wait_respond.sh
