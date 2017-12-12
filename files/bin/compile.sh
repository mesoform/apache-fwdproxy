#!/usr/bin/env bash

cd /tmp/httpd-${HTTPD_VER}
./configure --prefix=${PREFIX} \
        --sysconfdir=${CONFIG_DIR} \
        --enable-proxy-connect \
        --enable-proxy \
        --enable-proxy-http \
        --enable-vhost-alias \
        --enable-rewrite \
        --enable-so \
        --enable-deflate \
        --enable-mime-magic \
        --with-mpm=prefork \
        --with-included-apr \
        --with-port=${PROXY_PORT} && \
    make && \
    make install