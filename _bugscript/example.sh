set -e

ver=${ENVIRON:-10.2.8}

# just use current directory if called from framework
if [ ! -f common.sh ] ; then
  [ -d mariadb-environs ] || git clone http://github.com/AndriiNikitin/mariadb-environs
  cd mariadb-environs
  ./get_plugin.sh galera
fi

function onExit {
  [ "$passed" == 1 ] && exit
  cluster1/tail_log.sh 100
# uncomment if you wish docker build hang on failire (to attach to container and troubleshoot)
#  sleep 10000
}
trap onExit EXIT

_template/plant_cluster.sh cluster1
echo m0 > cluster1/nodes.lst
echo m1 >> cluster1/nodes.lst
echo m2 >> cluster1/nodes.lst
echo m3 >> cluster1/nodes.lst
cluster1/replant.sh ${ver}

./build_or_download.sh m0

# workaround MDEV-13283
[[ ! "$WSREP_EXTRA_OPT" =~ mysqldump ]] || \
  [ ! -d _depot/m-tar/${ver} ] || \
  sed -i "s/Distrib 10.1/Distrib 10/g" _depot/m-tar/${ver}/bin/wsrep_sst_mysqldump

# workaround MDEV-10477
[[ ! "$WSREP_EXTRA_OPT" =~ rsync ]] || \
  [ $(whoami) != root ] || \
  [ ! -d _depot/m-tar/${ver} ] || \
  sed -i '/read only = no/s/.*/&\nuid = root\ngid = root\n/' _depot/m-tar/${ver}/bin/wsrep_sst_rsync

# for debugging if needed -c configure wsrep_sst_method=rsyncx
# echo bash -x -v $(pwd)/_depot/m-tar/${ver}/bin/wsrep_sst_rsync '"$@"' > _depot/m-tar/${ver}/bin/wsrep_sst_rsyncx
# chmod +x _depot/m-tar/${ver}/bin/wsrep_sst_rsyncx

. cluster1/gen_cnf.sh general_log=1
. cluster1/install_db.sh
. cluster1/galera_setup_acl.sh
. cluster1/galera_start_new.sh $WSREP_EXTRA_OPT

sleep 45
. cluster1/galera_cluster_size.sh
. cluster1/sql.sh 'show variables like "wsrep_sst_method"'

grep -A10 -B10 -i "\[ERROR\]" m0*/dt/error.log || echo no errors found

cluster_size=$(m0*/sql.sh 'show status like "wsrep_cluster_size"')

[[ "${cluster_size}" =~ 4 ]] && passed=1
