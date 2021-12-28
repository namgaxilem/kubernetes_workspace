FROM openjdk:8-jre-alpine

ARG GID=1000
ARG UID=1000

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN apk update \
   && apk add curl wget bash openssl jq yq \
   && addgroup -g $GID nifi \
   && adduser -D -s /bin/ash -u $UID -G nifi nifi

COPY automation-script.sh /data/

RUN curl https://archive.apache.org/dist/nifi/1.15.0/nifi-toolkit-1.15.0-bin.tar.gz \
   -o /opt/nifi-toolkit/nifi-toolkit-1.15.0-bin.tar.gz --create-dirs
RUN tar -zxvf /opt/nifi-toolkit/nifi-toolkit-1.15.0-bin.tar.gz -C /opt/nifi-toolkit/

RUN chown -R nifi:nifi /data/ \
   && chown -R nifi:nifi /opt/

USER nifi

WORKDIR /data/
