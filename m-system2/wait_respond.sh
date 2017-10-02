#!/bin/bash
# galera needs to sleep some time to let node finish recovery
# disable galera plugin if you don't need this sleep

# first wait X seconds til pid file is created
counter=45
while [ "$counter" -ge 0 ] && [ ! -e __workdir/dt/p.id ] ; do
  sleep 1
  ((counter--))
done
mysqladmin --defaults-file=__workdir/my.cnf --wait=5 ping
