[ ! -z "$1" ] || exit 1

tee Dockerfile <<EOF
from centos:7

RUN yum -y install m4 git wget python cmake make gcc-c++ ncurses-devel bison zlib zlib-devel zlib-static openssl vim findutils openssl vim m4 libaio libnuma numactl gnutls-devel

COPY ${1}.sh ${1}.sh

RUN cat ${1}.sh

RUN bash -v -x ${1}.sh
EOF

docker build .

