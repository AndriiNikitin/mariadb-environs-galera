#!/bin/bash
set -e
first=1
for eid in $(cat __clusterdir/nodes.lst) ; do
  if [ "$first" == 1 ] ; then
    first=0
    echo -n $eid :
    . $eid*/galera_start_new.sh "$@"
#    donor_ip="$($eid*/sql.sh select @@hostname)"
#   currently only localhost cluster is implemented
    donor_ip=$(hostname -i)
    [ ! -z "$donor_ip" ] || { >&2 echo 'Couldn'"'"'t determine galera donor ip'; exit 1; }
  else
    echo -n $eid :
    . $eid*/galera_join.sh $donor_ip $donor_ip "$@"
  fi
done

