#!/bin/bash
set -e
donor=""
for eid in $(cat __clusterdir/nodes.lst) ; do
  if [ -z "$donor" ] ; then
  donor="$eid"
    echo -n $eid :
    . $eid*/galera_start_new.sh "$@"
#    donor_ip="$($eid*/galera_ip.sh)"
#    donor_port="$($eid*/galera_port.sh)"
#   currently only localhost cluster is implemented
#    donor_ip=$(hostname -i)
#    donor_port=$(hostname -i)
#    [ ! -z "$donor_ip" ] || { >&2 echo 'Couldn'"'"'t determine galera donor ip'; exit 1; }
  else
    echo -n $eid :
    . $eid*/galera_join.sh "${donor}" "$@"
  fi
done

