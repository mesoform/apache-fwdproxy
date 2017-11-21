#!/usr/bin/env bash

apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
      apt-get install -y -t jessie --no-install-recommends \
        net-tools \
        curl \
        libpcre3 \
        libpcre3-dev \
        build-essential \
        libaprutil1 \
        libaprutil1-dev


# Download the latest release from http://httpd.apache.org/download.cgi
cd /tmp/
curl -o httpd-${HTTPD_VER}.tar.gz ${DOWNLOAD_URL}
gzip -d httpd-${HTTPD_VER}.tar.gz
tar xvf httpd-${HTTPD_VER}.tar
cd httpd-${HTTPD_VER}
./configure --prefix=${PREFIX} \
        --sysconfdir=${CONFIG_DIR} \
        --enable-proxy-connect \
        --enable-proxy \
        --enable-proxy-http \
        --enable-vhost-alias \
        --enable-rewrite \
        --enable-so \
        --with-port=${PROXY_PORT} && \
    make && \
    make install
#Customize	$ vi PREFIX/conf/httpd.conf
#Test	$ PREFIX/bin/apachectl -k start