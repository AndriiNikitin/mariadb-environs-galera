#!/bin/bash

if [ -f /usr/lib/galera/libgalera_smm.so ] ; then
  echo wsrep_provider=/usr/lib/galera/libgalera_smm.so >> /etc/my.cnf
elif [ -f /usr/lib64/galera/libgalera_smm.so ] ; then
  echo wsrep_provider=/usr/lib64/galera/libgalera_smm.so >> /etc/my.cnf
else
  >&2 echo "Cannot find libgalera"
  exit 2
fi


cat >> /etc/my.cnf <<EOL
binlog_format=ROW
default-storage-engine=innodb
innodb_autoinc_lock_mode=2
bind-address=0.0.0.0

wsrep_on=ON
wsrep_sst_method=mysqldump
EOL

h=$(hostname -i)

echo wsrep_node_address=$h >> /etc/my.cnf
echo wsrep_node_name=$h >> /etc/my.cnf
echo wsrep_cluster_address=gcomm://$h >> /etc/my.cnf
echo wsrep_cluster_name=$h >> /etc/my.cnf

mysqld_safe --skip-syslog --wsrep-new-cluster --user=$(whoami) &
__workdir/wait_respond.sh