#!/bin/bash

# this must be run after install_db and before galera_start
set -e

# currently works only on localhost

firstnode=""

for eid in $(cat __clusterdir/nodes.lst) ; do
  was_started=no
  __clusterdir/../$eid*/status.sh &> /dev/null || { __clusterdir/../$eid*/startup.sh && was_started=yes; }
  $eid*/sql.sh create user /*M!100100 if not exists*/ "$(whoami)"@"$(__clusterdir/../$eid*/galera_ip.sh)"
  $eid*/sql.sh grant all on \*.\* to "$(whoami)"@"$(__clusterdir/../$eid*/galera_ip.sh)"
  $eid*/sql.sh create user /*M!100100 if not exists*/ "$(whoami)"@localhost || :
  $eid*/sql.sh grant all on \*.\* to "$(whoami)"@localhost || :
  $eid*/sql.sh create user /*M!100100 if not exists*/ "galera"@"127.0.0.1" identified by '"galera"'
  $eid*/sql.sh grant all on \*.\* to galera@127.0.0.1
  $eid*/sql.sh create user /*M!100100 if not exists*/ mysql@localhost
  $eid*/sql.sh grant all on \*.\* to mysql@localhost
  $eid*/sql.sh create user /*M!100100 if not exists*/ "mysql"@"127.0.0.1"
  $eid*/sql.sh grant all on \*.\* to mysql@127.0.0.1  
  $eid*/sql.sh create user /*M!100100 if not exists*/ "mysql"@"$(__clusterdir/../$eid*/galera_ip.sh)"
  $eid*/sql.sh grant all on \*.\* to "mysql"@"$(__clusterdir/../$eid*/galera_ip.sh)"
  $eid*/sql.sh create user /*M!100100 if not exists*/ "root"@"$(__clusterdir/../$eid*/galera_ip.sh)" || :
  $eid*/sql.sh grant all on \*.\* to "root"@"$(__clusterdir/../$eid*/galera_ip.sh)" || :
  [ "$was_started" == no ] || __clusterdir/../$eid*/shutdown.sh
done

