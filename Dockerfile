# Build Elasticsearch Container
ARG IMAGE_USER=geoffh1977
ARG IMAGE_NAME=openjdk8
ARG IMAGE_VERSION=latest

FROM ${IMAGE_USER}/${IMAGE_NAME}:${IMAGE_VERSION}
LABEL maintainer="geoffh1977 <geoffh1977@gmail.com>"

# hadolint ignore=DL3002
USER root

ARG ES_VERSION
ARG ES_SHA

ENV ES_VERSION ${ES_VERSION}
ENV ES_SHA ${ES_SHA}
ENV DOWNLOAD_URL "https://artifacts.elastic.co/downloads/elasticsearch"
ENV ES_TARBALL "${DOWNLOAD_URL}/elasticsearch-${ES_VERSION}.tar.gz"

# Install Elasticsearch.
# hadolint ignore=DL3003, DL3018, DL4006
RUN apk add --no-cache --update bash ca-certificates su-exec util-linux curl && \
  apk add --no-cache -t .build-deps gnupg openssl && \
  cd /tmp && \
  curl -o elasticsearch.tar.gz -Lskj "$ES_TARBALL" && \
  echo "${ES_SHA}  /tmp/elasticsearch.tar.gz" | sha512sum -c - && \
  tar -xf elasticsearch.tar.gz && \
  mv elasticsearch-$ES_VERSION /elasticsearch && \
  adduser -DH -s /sbin/nologin elasticsearch && \
  mkdir -p /elasticsearch/config/scripts /elasticsearch/plugins && \
  chown -R elasticsearch:elasticsearch /elasticsearch && \
  rm -rf /tmp/* && \
  apk del --purge .build-deps

ENV PATH /elasticsearch/bin:$PATH

COPY config /elasticsearch/config
COPY scripts/start.sh /usr/local/bin/

RUN chmod 0755 /usr/local/bin/start.sh && \
  chown elasticsearch:elasticsearch /usr/local/bin/start.sh /elasticsearch/config

# Set environment variables defaults
ENV ES_JAVA_OPTS "-Xms512m -Xmx512m"
ENV CLUSTER_NAME elasticsearch-default
ENV NODE_MASTER true
ENV NODE_DATA true
ENV NODE_INGEST true
ENV HTTP_ENABLE true
ENV NETWORK_HOST _site_
ENV HTTP_CORS_ENABLE true
ENV HTTP_CORS_ALLOW_ORIGIN *
ENV NUMBER_OF_MASTERS 1
ENV MAX_LOCAL_STORAGE_NODES 1
ENV SHARD_ALLOCATION_AWARENESS ""
ENV SHARD_ALLOCATION_AWARENESS_ATTR ""
ENV MEMORY_LOCK true
ENV REPO_LOCATIONS ""

WORKDIR /elasticsearch
VOLUME ["/data"]
EXPOSE 9200/tcp 9300/tcp

CMD ["/usr/local/bin/start.sh"]
