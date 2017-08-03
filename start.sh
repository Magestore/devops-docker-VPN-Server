#!/bin/sh
sudo modprobe af_key

mkdir -p etc/ipsec.d
mkdir -p etc/ppp

if [ ! -f etc/ipsec.d/passwd ]; then
	touch etc/ipsec.d/passwd
fi

if [ ! -f etc/ppp/chap-secrets ]; then
	touch etc/ppp/chap-secrets
fi

if [ ! -f etc/ipsec.secrets ]; then
	touch etc/ipsec.secrets
fi

PWD=$( pwd )
EXTRA_ARGS=
if [ -f etc/pre-up.sh ]; then
    EXTRA_ARGS="-v $PWD/etc/pre-up.sh:/pre-up.sh"
fi

docker run \
    --name ipsec-vpn-server \
    -p 500:500/udp \
    -p 4500:4500/udp \
    -v /lib/modules:/lib/modules:ro \
    -v "$PWD/etc/ppp/chap-secrets:/etc/ppp/chap-secrets" \
    -v "$PWD/etc/ipsec.d/passwd:/etc/ipsec.d/passwd" \
    -v "$PWD/etc/ipsec.secrets:/etc/ipsec.secrets" \
    $EXTRA_ARGS \
    -v /lib/modules:/lib/modules:ro \
    -d --privileged \
    --restart=always \
    magestore/docker-ipsec-vpn-server
