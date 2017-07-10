[ ! -z "$1" ] || exit 1

tee Dockerfile <<EOF
from centos:7

RUN yum -y install m4 git wget python cmake make gcc-c++ ncurses-devel bison zlib zlib-devel zlib-static openssl vim findutils openssl vim m4 libaio libnuma numactl gnutls-devel openssl098e

COPY ${1:example}.sh ${1:example}.sh

RUN cat ${1:example}.sh

ENV WORKAROUND "$WORKAROUND"
ENV WSREP_EXTRA_OPT "$WSREP_EXTRA_OPT"

RUN bash -v -x ${1:example}.sh
EOF

docker build .

