#!/bin/bash
# galera needs to sleep some time to let node finish recovery
# disable galera plugin if you don't need this sleep
sleep 15
sudo mysqladmin --wait=5 ping
