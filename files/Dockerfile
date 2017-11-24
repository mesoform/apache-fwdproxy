FROM mesoform/concierge-debian-base-image:concierge-0.1.6

# Add some labels
LABEL maintainer="Gareth Brown <gareth@mesoform.com>"
LABEL description="Apache HTTPD set up as a forward proxy to Google API proxy"
LABEL com.mesoform.baseimage=False
LABEL com.joyent.autopilotpattern=True
LABEL com.mesoform.builddate="2017-11-24T00:05:14Z"
LABEL com.mesoform.baseimage.ver="mesoform/concierge-debian-base-image:concierge-0.1.6"
LABEL com.docker.img.ver="mesoform/concierge-apache-fwdproxy:ver-0.1.0"

# Set some environment variables
ENV DOCKER_IMG_VER="mesoform/concierge-apache-fwdproxy:ver-0.1.0"
ENV DNS_DOMAIN=Apache-fwdproxy.gcpservices.mesoform.com
ENV CONSUL_AGENT=True
ENV CONSUL_VERSION=0.8.5
ENV CONSUL_CHECKSUM=35dc317c80862c306ea5b1d9bc93709483287f992fd0797d214d1cc1848e7b62
ENV LOG_LEVEL="INFO"
ENV LOG_FORMAT="text"
ENV PREFIX=/usr/local/apache

# Set some build arguments
ARG HTTPD_VER=2.4.29
ARG PREFIX=/usr/local/apache
ARG DOWNLOAD_URL=http://apache.mirror.anlx.net//httpd/httpd-${HTTPD_VER}.tar.gz
ARG CONFIG_DIR=/etc/Apache-fwdproxy
ARG PROXY_PORT=300031


# If we have any install scripts, run them.
RUN chmod -R +x /usr/local/bin/install.sh && \
    /usr/local/bin/install.sh

# make directories
RUN mkdir -p /var/www/httpd-data 
# define volumes if set
VOLUME [ "/var/www/httpd-data"  ]

# The command we pass to Containerpilot to start the application
RUN chmod ug+x /usr/local/apache/bin/apachectl
CMD [ "/usr/local/apache/bin/apachectl -k start" ]
