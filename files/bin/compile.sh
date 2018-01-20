#!/usr/bin/env bash

cd /tmp/httpd-${HTTPD_VER}
./configure --prefix=${PREFIX} \
        --sysconfdir=${CONFIG_DIR} \
        --enable-proxy-connect \
        --enable-proxy-balancer \
        --enable-proxy \
        --enable-proxy-http \
        --enable-lbmethod-bybusyness \
        --enable-vhost-alias \
        --enable-rewrite \
        --enable-so \
        --enable-deflate \
        --enable-mime-magic \
        --with-mpm=worker \
        --with-included-apr \
        --with-port=${PROXY_PORT} && \
    make && \
    make install && \
    make clean

apt-get purge libpcre3-dev \
    zlib1g-dev \
    build-essential \
    libapr1-dev \
    libaprutil1-dev
apt-get autoremove
apt-get clean

rm -rf /var/lib/apt/lists/* \
    /tmp/httpd-${HTTPD_VER}.* \
    /tmp/apr-1.6.3.* \
    /tmp/apr-util-1.6.1.*