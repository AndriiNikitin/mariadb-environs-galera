p="$(__workdir/galera_port.sh)"
if [ "$p" == 4567 ]; then
  echo $(__workdir/galera_ip.sh)
else
  echo $(__workdir/galera_ip.sh):$p
fi

