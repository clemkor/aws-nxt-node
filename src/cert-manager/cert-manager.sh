#!/bin/bash

set -e
set -o pipefail

echo "Fetching certificate..."
certbot certonly \
    --non-interactive \
    --manual \
    --test-cert \
    --manual-public-ip-logging-ok \
    --manual-auth-hook /opt/cert-manager/scripts/route53-auth-hook.sh \
    --manual-cleanup-hook /opt/cert-manager/scripts/route53-cleanup-hook.sh \
    --config-dir /opt/cert-manager/certs/ \
    --logs-dir /opt/cert-manager/logs/ \
    --work-dir /opt/cert-manager/work/ \
    --agree-tos \
    --preferred-challenges dns \
    --domain ${CERT_MANAGER_DOMAIN} \
    --email ${CERT_MANAGER_EMAIL}
