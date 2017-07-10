set -e

ver=10.2.6

git clone http://github.com/AndriiNikitin/mariadb-environs
cd mariadb-environs
./get_plugin.sh galera

_template/plant_cluster.sh cluster1
cat cluster1/nodes.lst
cluster1/replant.sh ${ver}
m0*/download.sh

[ -z "$WORKAROUND_MDEV13283" ] || sed -i "s/Distrib 10.1/Distrib 10.^0" _depot/m-tar/${ver}/bin/wsrep_mysqldump.sh

cluster1/gen_cnf.sh
cluster1/install_db.sh
cluster1/galera_setup_acl.sh
cluster1/galera_start_new.sh

sleep 45
cluster1/galera_cluster_size.sh

