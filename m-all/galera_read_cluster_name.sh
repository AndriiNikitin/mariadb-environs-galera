set +x
n="$(__workdir/sql.sh 'show variables like "wsrep_cluster_name"')"
# split tail in string like 'wsrep_cluster_name 192.168.1.183_4567'
# and print only 192.168.1.183_4567
n="${n##wsrep_cluster_name}"
echo $n
