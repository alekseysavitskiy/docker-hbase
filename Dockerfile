FROM java:8-jre-alpine
MAINTAINER Denis Baryshev <dennybaa@gmail.com>

ENV HBASE_VERSION 1.2.2
ENV HBASE_HOME /usr/local/hbase-${HBASE_VERSION}
ENV HBASE_CONF_DIR /etc/hbase
# Default port to connect Zookeeper to
ENV ZK_PORT 2181

LABEL vendor=ActionML \
      version_tags="[\"1.2\",\"1.2.2\"]"

# Update alpine and install required tools
RUN apk update && apk add --update bash curl && \
  curl -L http://nl.alpinelinux.org/alpine/edge/community/x86_64/shadow-4.2.1-r6.apk \
       -o /tmp/shadow.apk && apk add /tmp/shadow.apk && rm /tmp/*

## Fetch, unpack hbase dist and prepare layout
RUN curl -L http://www-us.apache.org/dist/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz \
      | tar -xzp -C /usr/local && \
      mv ${HBASE_HOME}/conf ${HBASE_CONF_DIR} && \
      ln -s ${HBASE_CONF_DIR} ${HBASE_HOME}/conf

## Install confd
RUN curl -L https://github.com/kelseyhightower/confd/releases/download/v0.12.0-alpha3/confd-0.12.0-alpha3-linux-amd64 \
          -o /usr/local/bin/confd && chmod 755 /usr/local/bin/confd

## Create users (to go "non-root") and set directory permissions
RUN useradd -mU -d /home/hadoop hadoop && passwd -d hadoop && \
      useradd -mU -d /home/hbase -G hadoop hbase && passwd -d hbase

## Add configuration and scripts into container
ADD ./conf/* /etc/hbase
ADD ./conf.d /etc/confd/conf.d
ADD ./templates /etc/confd/templates
ADD ./*.sh /

## Volumes
VOLUME [ "/etc/hbase" ]

ENTRYPOINT [ "/entrypoint.sh" ]

# Hbase exposed ports
EXPOSE 16000 16010 16020 16030
