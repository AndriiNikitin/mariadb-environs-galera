ENVIRON=${ENVIRON:-10.2.6}

tee Dockerfile <<EOF
from centos:7

RUN yum -y install m4 git wget python cmake make gcc-c++ ncurses-devel bison zlib zlib-devel zlib-static openssl vim findutils openssl vim m4 libaio libnuma numactl gnutls-devel openssl098e socat lsof iproute net-tools bc

RUN yum -y install http://www.percona.com/downloads/percona-release/redhat/0.1-4/percona-release-0.1-4.noarch.rpm

RUN yum -y install percona-xtrabackup-24

ENV ENVIRON $ENVIRON

RUN git clone https://github.com/AndriiNikitin/mariadb-environs
WORKDIR mariadb-environs

RUN bash get_plugin.sh galera
RUN bash replant.sh m0-${ENVIRON}
RUN bash build_or_download.sh m0

COPY ${1:-example}.sh ${1:-example}.sh

ENV WORKAROUND "$WORKAROUND"
ENV WSREP_EXTRA_OPT "$WSREP_EXTRA_OPT"

RUN bash -v -x ${1:-example}.sh
EOF

docker build .

