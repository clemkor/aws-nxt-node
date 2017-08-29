#!/bin/bash

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
eval $(cat /opt/nxt/conf/nxt-default.env | sed 's/^/export /')

# Fetch and source overrides env file
eval $(aws s3 cp --sse AES256 --region ${AWS_REGION} \
    ${AWS_S3_CONFIGURATION_OBJECT} - | sed 's/^/export /')

# Render properties template
cat /opt/nxt/conf/nxt.properties.template \
    | envsubst > /opt/nxt/conf/nxt.properties

# Start NXT
cd /opt/nxt
./run.sh