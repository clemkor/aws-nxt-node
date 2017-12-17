#!/bin/bash

set -e
set -o pipefail

# Ensure AWS_REGION environment variable is present
if [ -z "$AWS_REGION" ]; then
  echo >&2 'Error: missing AWS_REGION environment variable.'
  exit 1
fi

# Ensure AWS_S3_CONFIGURATION_OBJECT environment variable is present
if [ -z "$AWS_S3_CONFIGURATION_OBJECT" ]; then
  echo >&2 'Error: missing AWS_S3_CONFIGURATION_OBJECT environment variable.'
  exit 1
fi

# Source default env file
echo "Sourcing default NXT configuration."
eval $(cat /opt/nxt/conf/nxt-default.env | sed 's/^/export /')

# Fetch and source overrides env file
echo "Fetching and sourcing override NXT configuration."
eval $(aws s3 cp --sse AES256 --region ${AWS_REGION} \
    ${AWS_S3_CONFIGURATION_OBJECT} - | sed 's/^/export /')

# Fetch initial database archive if specified and not already present
if [ -n "$NXT_INITIAL_BLOCKCHAIN_ARCHIVE_PATH" ]; then
    if [ ! -f "/opt/nxt/nxt_db/nxt.h2.db" ]; then
        echo "Fetching initial blockchain archive from ${NXT_INITIAL_BLOCKCHAIN_ARCHIVE_PATH}."
        aws s3 cp --sse AES256 --region ${AWS_REGION} \
            ${NXT_INITIAL_BLOCKCHAIN_ARCHIVE_PATH} \
            /tmp/blockchain_archive.zip
        unzip /tmp/blockchain_archive.zip -d /opt/nxt/nxt_db
        rm /tmp/blockchain_archive.zip
        echo "Fetched initial blockchain archive."
    fi
fi

# Render properties template
echo "Rendering NXT properties file."
cat /opt/nxt/conf/nxt.properties.template \
    | envsubst > /opt/nxt/conf/nxt.properties

# Move to NXT directory
cd /opt/nxt

# Start NXT
echo "Starting NXT."
./run.sh
