#!/bin/bash

if [ -f /usr/lib/galera/libgalera_smm.so ] ; then
  echo wsrep_provider=/usr/lib/galera/libgalera_smm.so >> __workdir/mysqldextra.cnf
elif [ -f /usr/lib64/galera/libgalera_smm.so ] ; then
  echo wsrep_provider=/usr/lib64/galera/libgalera_smm.so >> __workdir/mysqldextra.cnf
elif [ ! -z "$(echo __workdir/../_depot/m-tar/*/lib/libgalera_smm.so 2>/dev/null | head -n1)" ] ; then
  echo wsrep_provider=$(echo __workdir/../_depot/m-tar/*/lib/libgalera_smm.so 2>/dev/null | head -n1) >> __workdir/mysqldextra.cnf
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

h=$(hostname -i)

echo wsrep_node_address=$h >> __workdir/mysqldextra.cnf
echo wsrep_node_name=$h >> __workdir/mysqldextra.cnf
echo wsrep_cluster_address=gcomm://$h >> __workdir/mysqldextra.cnf
echo wsrep_cluster_name=$h >> __workdir/mysqldextra.cnf

[ ! -z "$1" ] && for o in $@ ; do
  echo $o >> __workdir/mysqldextra.cnf
done



# this to let galera find mysqldump and mysql
export PATH=__blddir/client:__srcdir/scripts:__blddir/extra:$PATH

bash __srcdir/scripts/mysqld_safe.sh --defaults-file=__workdir/my.cnf --skip-syslog --ledir=__blddir/sql --user=$(whoami) --wsrep-new-cluster & 
sleep 5
__workdir/wait_respond.sh
