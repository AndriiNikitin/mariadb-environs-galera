set -e

MDBVER=${ENVIRON:-10.1.16}

# just use current directory if called from framework
if [ ! -f common.sh ] ; then
  [ -d mariadb-environs ] || git clone http://github.com/AndriiNikitin/mariadb-environs
  cd mariadb-environs
fi

./get_plugin.sh galera

# set up cluster
_template/plant_cluster.sh cluster1
echo m0 > cluster1/nodes.lst
echo m1 >> cluster1/nodes.lst
echo m2 >> cluster1/nodes.lst
echo m3 >> cluster1/nodes.lst
cat cluster1/nodes.lst
cluster1/replant.sh ${MDBVER}

# download tar
./build_or_download.sh m0

# workaround MDEV-10477
[ $(whoami) != root ] || \
  [ ! -d _depot/m-tar/${ver} ] || \
  sed -i '/read only = no/s/.*/&\nuid = root\ngid = root\n/' _depot/m-tar/${MDBVER}/bin/wsrep_sst_rsync


# create rsync_buggy to emulate this error on donor:
# rsync: failed to connect to {} : Connection refused (111)
# rsync error: error in socket IO (code 10) at clientserver.c(128)
sed '/ready \$ADDR\/\$MODULE/s/.*/echo ready \$\{ADDR\}1\/\$MODULE/' _depot/m-tar/${MDBVER}/bin/wsrep_sst_rsync > _depot/m-tar/${MDBVER}/bin/wsrep_sst_rsync_buggy
chmod +x _depot/m-tar/${MDBVER}/bin/wsrep_sst_rsync_buggy

# setup default four nodes cluster
. cluster1/gen_cnf.sh general_log=1
. cluster1/install_db.sh
. cluster1/galera_setup_acl.sh
. cluster1/galera_start_new.sh wsrep_sst_method=rsync

sleep 45
# make sure 4 is cluster size on every node
. cluster1/galera_cluster_size.sh

m0*/sql.sh create table t select 1

# put some load on every node in cluster 
( for i in {1..10000} ; do m"$(echo $i % 4|bc)"*/sql.sh insert into test.t select $i ; done ) &>/dev/null &

# get 5th node ready
./replant.sh m4-${MDBVER}
m4*/gen_cnf.sh
m4*/install_db.sh

sleep 10
# now join node with buggy script rsync_buggy, which will generate error 110 connection refused on donor
# and observe that cluster is functioning properly
cluster1/sql.sh 'select count(*) from test.t'

m4*/galera_join.sh $(m0*/galera_ip.sh) $(m0*/galera_ip.sh) wsrep_sst_method=rsync_buggy || true

cluster1/sql.sh 'select count(*) from test.t'
sleep 30

grep -A20 -B20 ERROR m*/dt/error.log

cluster1/sql.sh 'select count(*) from test.t'
cluster1/sql.sh show processlist

