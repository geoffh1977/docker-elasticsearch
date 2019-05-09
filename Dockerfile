# Build Elasticsearch Container
FROM geoffh1977/openjdk8:latest
LABEL maintainer="geoffh1977 <geoffh1977@gmail.com>"

# hadolint ignore=DL3002
USER root

ENV ES_VERSION=6.7.2 \
    ES_SHA=7e2dd65dc10d117002dca309d5fd450e218d06f8ff5ed675a219c5bfb1367afdb7f00f9a5866628e475da38c91692e9eff29140c25cf1779fb71619ff50d784c \
    ES_TARBALL="https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.7.2.tar.gz"

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
ENV ES_JAVA_OPTS="-Xms512m -Xmx512m" \
    CLUSTER_NAME=elasticsearch-default \
    NODE_MASTER=true \
    NODE_DATA=true \
    NODE_INGEST=true \
    HTTP_ENABLE=true \
    NETWORK_HOST=_site_ \
    HTTP_CORS_ENABLE=true \
    HTTP_CORS_ALLOW_ORIGIN=* \
    NUMBER_OF_MASTERS=1 \
    MAX_LOCAL_STORAGE_NODES=1 \
    SHARD_ALLOCATION_AWARENESS="" \
    SHARD_ALLOCATION_AWARENESS_ATTR="" \
    MEMORY_LOCK=true \
    REPO_LOCATIONS=""

WORKDIR /elasticsearch
VOLUME ["/data"]
EXPOSE 9200/tcp 9300/tcp

CMD ["/usr/local/bin/start.sh"]
