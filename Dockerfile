FROM java:8-jre-alpine
MAINTAINER Denis Baryshev <dennybaa@gmail.com>

ENV HBASE_VERSION 2.1.4
ENV HBASE_HOME /usr/local/hbase-${HBASE_VERSION}
ENV HBASE_CONF_DIR /etc/hbase
# Default port to connect Zookeeper to
ENV ZK_PORT 2181

LABEL vendor=ActionML \
      version_tags="[\"2.1\",\"2.1.4\"]"

# Update alpine and install required tools
RUN echo "@community http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk add --update --no-cache bash curl shadow@community

## Fetch, unpack hbase dist and prepare layout
RUN curl -L http://www-us.apache.org/dist/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz \
      | tar -xzp -C /usr/local && \
      mv ${HBASE_HOME}/conf ${HBASE_CONF_DIR} && \
      ln -s ${HBASE_CONF_DIR} ${HBASE_HOME}/conf

## Install confd
RUN curl -L https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 \
          -o /usr/local/bin/confd && chmod 755 /usr/local/bin/confd

## Create users (to go "non-root") and set directory permissions
RUN useradd -mU -d /home/hadoop hadoop && passwd -d hadoop && \
      useradd -mU -d /home/hbase -G hadoop hbase && passwd -d hbase

## Add configuration and scripts into container
ADD ./conf/* /etc/hbase/
ADD ./conf.d /etc/confd/conf.d
ADD ./templates /etc/confd/templates
ADD ./*.sh /
RUN curl -L -O https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.3.1/jmx_prometheus_javaagent-0.3.1.jar
## Volumes
VOLUME [ "/etc/hbase" ]

ENTRYPOINT [ "/entrypoint.sh" ]

# Hbase exposed ports
EXPOSE 16000 16010 16020 16030 7071
