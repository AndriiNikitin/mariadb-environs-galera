#!/bin/bash

[ ! -z "$1" ] || { echo "Expected name of Galera cluster as first parameter; got ($1)";  exit 2; }
[ ! -z "$2" ] || { echo "Expected IP of Galera node in 2nd parameter; got ($2)";  exit 2; }

cluster_name=$1
join_ip=$2

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
echo wsrep_cluster_name=$cluster_name  >> /etc/my.cnf
echo wsrep_cluster_address="gcomm://$join_ip" >> /etc/my.cnf

mysqld_safe --loose-syslog=0 --user=$(whoami) &
__workdir/wait_respond.sh