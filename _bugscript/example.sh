set -e

ver=10.2.6

[ -d mariadb-environs ] || git clone http://github.com/AndriiNikitin/mariadb-environs
cd mariadb-environs
./get_plugin.sh galera

_template/plant_cluster.sh cluster1
cat cluster1/nodes.lst
cluster1/replant.sh ${ver}
m0*/download.sh

# workaround MDEV-13283
sed -i "s/Distrib 10.1/Distrib 10/g" _depot/m-tar/${ver}/bin/wsrep_sst_mysqldump

cluster1/gen_cnf.sh
cluster1/install_db.sh
cluster1/galera_setup_acl.sh
cluster1/galera_start_new.sh $WSREP_EXTRA_OPT

sleep 45
cluster1/galera_cluster_size.sh
cluster1/sql.sh 'show variables like "wsrep_sst_method"'

grep -A10 -B10 -i "\[ERROR\]" m0*/dt/error.log || echo no errors found

cluster_size=$(m0*/sql.sh 'show status like "wsrep_cluster_size"')

[[ "${cluster_size}" =~ 4 ]]
