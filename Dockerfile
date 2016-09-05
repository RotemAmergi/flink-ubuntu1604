############################################################
# Dockerfile to build flink  container images
# Based on ubuntu:16.04
############################################################
# Set the base image to Ubuntu
FROM ubuntu:16.04
# File Author / Maintainer
MAINTAINER  rotem@secupi.com
ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No
ENV LANG en_US.UTF-8
ENV HADOOP_VERSION 2.7.0
ENV FLINK_VERSION 1.0.3
ENV SCALA_VERSION 2.11
ARG FLINK_INSTALL_PATH=/opt
ENV FLINK_ROOT_DIR /opt/flink
ENV FLINK_HOME $FLINK_ROOT_DIR
ENV PATH $PATH:$FLINK_ROOT_DIR/bin
################## BEGIN INSTALLATION ######################
RUN apt-get update -y && \
    apt-get install -y wget  && \
    apt-get install -y nano  && \
    apt-get install -y iputils-ping && \
    apt-get -y upgrade  && \
    apt-get install --no-install-recommends -y openjdk-8-jre-headless && \
    apt-get clean && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*
# Get Flink from US Apache mirror.
RUN mkdir -p /opt && \
    cd /opt && \
    curl http://www.us.apache.org/dist/flink/flink-${FLINK_VERSION}/flink-${FLINK_VERSION}-bin-hadoop27-scala_${SCALA_VERSION}.tgz | \
        tar -zx && \
    ln -s flink-${FLINK_VERSION} flink && \
    groupadd --system  flink && \
    useradd  --system -g  flink -d $FLINK_HOME flink && \
    passwd -d flink && \
    chown -R flink:flink $FLINK_INSTALL_PATH/flink-$FLINK_VERSION && \
    chown -h flink:flink $FLINK_HOME && \
    sed -i -e "s/echo \$mypid >> \$pid/echo \$mypid >> \$pid \&\& wait/g" $FLINK_HOME/bin/flink-daemon.sh && \
    echo Flink ${FLINK_VERSION} installed in /opt
##################### INSTALLATION END #####################
# Configure containe
USER flink
ADD docker-entrypoint.sh /opt/flink/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
