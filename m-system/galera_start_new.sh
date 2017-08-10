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

[ ! -z "$1" ] && for o in $@ ; do
  echo $o >> __workdir/mysqldextra.cnf
done


mysqld_safe --skip-syslog --wsrep-new-cluster --user=$(whoami) &
__workdir/wait_respond.sh
