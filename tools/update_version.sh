#!/bin/bash
# Update The Software Version From Online

# Get The Versions Of The Software

SITE_VERSION=$(curl -s https://www.elastic.co/downloads/elasticsearch | grep -shoP 'http.*?[" >]' | grep tar.gz | grep -v sha1 | sed -e 's/^.*elasticsearch-//g' -e 's/\.tar\.gz.*$//g' | grep -v "-" | sort -u | tail -n1)
LOCAL_VERSION=$(grep "finalImageVersion" container.conf | cut -d= -f 2)

# Check Versions And Update File
if [ "$SITE_VERSION" != "$LOCAL_VERSION" ]
then
  sed -i "s/^finalImageVersion=.*/finalImageVersion=${SITE_VERSION}/" container.conf
  SHA=$(curl -s "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${SITE_VERSION}.tar.gz.sha512" | awk '{print $1}')
  sed -i "s/^elasticsearchSha512=.*/elasticsearchSha512=${SHA}/" container.conf
  echo " Version Updated."
else
  echo " No Version Change."
fi
