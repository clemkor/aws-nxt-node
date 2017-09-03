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

# Move to NXT directory
cd /opt/nxt

# Source default env file
eval $(cat conf/nxt-default.env | sed 's/^/export /')

# Fetch and source overrides env file
eval $(aws s3 cp --sse AES256 --region ${AWS_REGION} \
    ${AWS_S3_CONFIGURATION_OBJECT} - | sed 's/^/export /')

# Render properties template
cat conf/nxt.properties.template \
    | envsubst > conf/nxt.properties

# Fetch initial database archive if specified
if [ -n "$NXT_INITIAL_BLOCKCHAIN_ARCHIVE_URL" ]; then
    mkdir tmp
    curl -L "$NXT_INITIAL_BLOCKCHAIN_ARCHIVE_URL" -o tmp/blockchain_archive.zip
    unzip tmp/blockchain_archive.zip -d nxt_db
    rm -rf tmp
fi

# Start NXT
./run.sh
