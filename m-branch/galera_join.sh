#!/bin/bash

[ ! -z "$1" ] || { echo "Expected name of Galera cluster as first parameter; got ($1)";  exit 2; }
[ ! -z "$2" ] || { echo "Expected IP of Galera node in 2nd parameter; got ($2)";  exit 2; }

cluster_name=$1

join_ip=$2

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

set -x

echo wsrep_cluster_name=$cluster_name  >> __workdir/mysqldextra.cnf
# check if we join the same host
if [ "$join_ip" != "$h" ] ; then
  # configure for remote node on default port
  echo wsrep_node_address=$h >> __workdir/mysqldextra.cnf
  echo wsrep_node_name=$h >> __workdir/mysqldextra.cnf
  echo wsrep_cluster_address="gcomm://$join_ip" >> __workdir/mysqldextra.cnf
else
  # configure for node on the same host
  galera_port=$((__wid+4567))
  echo wsrep_node_address=${h}:${galera_port} >> __workdir/mysqldextra.cnf
  echo wsrep_node_name=${h}${galera_port} >> __workdir/mysqldextra.cnf
  echo wsrep_cluster_address="gcomm://$join_ip:4567" >> __workdir/mysqldextra.cnf
fi

shift
shift

[ ! -z "$1" ] && for o in $@ ; do
  echo $o >> __workdir/mysqldextra.cnf
done

# this to let galera find mysqldump and mysql
export PATH=__blddir/client:__srcdir/scripts:__blddir/extra:$PATH

bash __srcdir/scripts/mysqld_safe.sh --defaults-file=__workdir/my.cnf --ledir=__blddir/sql --skip-syslog --user=$(whoami) &
sleep 20
__workdir/wait_respond.sh
