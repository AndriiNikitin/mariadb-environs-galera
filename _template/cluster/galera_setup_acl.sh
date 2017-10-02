#!/bin/bash

# this must be run after install_db and before galera_start
set -e

# currently works only on localhost

firstnode=""

for eid in $(cat __clusterdir/nodes.lst) ; do
  [ -z "$firstnode" ] || firstnode=$eid
  $eid*/startup.sh
  $eid*/sql.sh create user if not exists "$(whoami)"@"$(__clusterdir/../$eid*/galera_ip.sh)"
  $eid*/sql.sh grant all on \*.\* to "$(whoami)"@"$(__clusterdir/../$eid*/galera_ip.sh)"
  $eid*/sql.sh create user if not exists "$(whoami)"@localhost
  $eid*/sql.sh grant all on \*.\* to "$(whoami)"@localhost
  $eid*/sql.sh create user if not exists "galera"@"127.0.0.1" identified by '"galera"'
  $eid*/sql.sh grant all on \*.\* to galera@127.0.0.1
  $eid*/sql.sh create user if not exists mysql@localhost
  $eid*/sql.sh grant all on \*.\* to mysql@localhost
  $eid*/sql.sh create user if not exists "mysql"@"127.0.0.1"
  $eid*/sql.sh grant all on \*.\* to mysql@127.0.0.1  
  $eid*/shutdown.sh
done

