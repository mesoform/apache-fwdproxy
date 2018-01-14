#!/usr/bin/env bash

apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
      apt-get install -y -t jessie --no-install-recommends \
        net-tools \
        telnet \
        vim \
        curl \
        libpcre3 \
        libpcre3-dev \
        libxml2 \
        liblua5.1-0 \
        zlib1g-dev \
        build-essential \
        libapr1 \
        libapr1-dev \
        libaprutil1 \
        libaprutil1-dev


# Download the latest release from http://httpd.apache.org/download.cgi
cd /tmp/
curl -o httpd-${HTTPD_VER}.tar.gz ${DOWNLOAD_URL}
curl -o apr-1.6.3.tar.gz http://mirror.vorboss.net/apache//apr/apr-1.6.3.tar.gz
curl -o apr-util-1.6.1.tar.gz http://mirror.vorboss.net/apache//apr/apr-util-1.6.1.tar.gz
gzip -d httpd-${HTTPD_VER}.tar.gz
gzip -d apr-1.6.3.tar.gz
gzip -d apr-util-1.6.1.tar.gz
tar xvf httpd-${HTTPD_VER}.tar
cd httpd-${HTTPD_VER}
tar xvf /tmp/apr-1.6.3.tar -C srclib/
mv srclib/apr-1.6.3 srclib/apr
tar xvf /tmp/apr-util-1.6.1.tar -C srclib/
mv srclib/apr-util-1.6.1 srclib/apr-util
mkdir /var/log/apache-fwdproxy
