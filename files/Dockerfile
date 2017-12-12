FROM mesoform/concierge-debian-base-image:devtest

# Add some labels
LABEL maintainer="Gareth Brown <gareth@mesoform.com>"
LABEL description="Apache HTTPD set up as a forward proxy to Google API proxy"
LABEL com.mesoform.baseimage=False
LABEL com.joyent.autopilotpattern=True
LABEL com.mesoform.builddate="2017-12-12T00:07:52Z"
LABEL com.mesoform.baseimage.ver="mesoform/concierge-debian-base-image:devtest"
LABEL com.docker.img.ver="mesoform/concierge-apache-fwdproxy:ver-0.1.0"

# Set some environment variables
ENV DOCKER_IMG_VER="mesoform/concierge-apache-fwdproxy:ver-0.1.0"
ENV DNS_DOMAIN=apache-fwdproxy.gcpservices.mesoform.com
RUN unset CONSUL_AGENT
ENV LOG_LEVEL="INFO"
ENV LOG_FORMAT="text"
ENV PREFIX=/usr/local/apache

# Set some build arguments
ARG HTTPD_VER=2.4.29
ARG PREFIX=/usr/local/apache
ARG DOWNLOAD_URL=http://apache.mirror.anlx.net//httpd/httpd-${HTTPD_VER}.tar.gz
ARG CONFIG_DIR=/etc/apache-fwdproxy
ARG PROXY_PORT=30031


# If we have any install scripts, run them.
RUN chmod -R +x /usr/local/bin/install.sh && \
    /usr/local/bin/install.sh
RUN chmod -R +x /usr/local/bin/compile.sh && \
    /usr/local/bin/compile.sh

# make directories
RUN mkdir -p /var/www/httpd-data 
# define volumes if set
VOLUME [ "/var/www/httpd-data"  ]


# Expose primary service port
EXPOSE 30031
