#!/bin/bash
# galera needs to sleep some time to let node finish recovery
# disable galera plugin if you don't need this sleep

# first wait X seconds til pid file is created
counter=45
if [ "$counter" -ge 0 ] && [ ! -e __workdir/dt/p.id ] ; then
  sleep 1
  $((decr counter))
fi
mysqladmin --defaults-file=__workdir/my.cnf --wait=5 ping
