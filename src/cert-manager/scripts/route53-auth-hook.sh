#!/bin/bash

set -e
set -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CERT_MANAGER_ACTION="UPSERT" "${SCRIPT_DIR}/route53-verification-record-manager.sh"
