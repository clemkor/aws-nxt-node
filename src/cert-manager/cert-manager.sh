#!/bin/bash

set -e
set -o pipefail

certbot certonly \
    --manual \
    --test-cert \
    --preferred-challenges dns \
    -d ${CERT_MANAGER_DOMAIN} \
    -m ${CERT_MANAGER_EMAIL}
