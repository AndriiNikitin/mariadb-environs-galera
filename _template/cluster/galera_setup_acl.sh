#!/bin/bash

# this must be run after install_db and before galera_start
set -e

# currently works only on localhost

for eid in $(cat __clusterdir/nodes.lst) ; do
  $eid*/startup.sh
  $eid*/sql.sh create user "$(whoami)"@"$(hostname -i)"
  $eid*/sql.sh grant all on \*.\* to "$(whoami)"@"$(hostname -i)"
  $eid*/shutdown.sh
done

