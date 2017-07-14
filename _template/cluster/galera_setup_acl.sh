#!/bin/bash

# this must be run after install_db and before galera_start
set -e

# currently works only on localhost

for eid in $(cat __clusterdir/nodes.lst) ; do
  $eid*/startup.sh
  $eid*/sql.sh create user if not exists "$(whoami)"@"$(hostname -i)"
  $eid*/sql.sh grant all on \*.\* to "$(whoami)"@"$(hostname -i)"
  $eid*/sql.sh create user if not exists "galera"@"127.0.0.1" identified by '"galera"'
  $eid*/sql.sh grant all on \*.\* to galera@127.0.0.1
  $eid*/shutdown.sh
done

