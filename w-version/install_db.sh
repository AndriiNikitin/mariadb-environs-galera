#!/bin/bash
__workdir/../_depot/w-tar/__version/*/mysql_install_db --defaults-file=__workdir/my.cnf --datadir=__workdir/dt --user=$(whoami) --basedir=__workdir/../_depot/w-tar/__version && mkdir -p __workdir/dt/test

