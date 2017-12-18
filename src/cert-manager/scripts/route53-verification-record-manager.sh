#!/bin/bash

set -e
set -o pipefail

echo "Building ${CERT_MANAGER_ACTION} change batch JSON..."
change_batch=$(cat /opt/cert-manager/templates/route53-change-batch.json.template | envsubst)

echo "Submitting change batch..."
change_info=$(aws route53 change-resource-record-sets --cli-input-json "${change_batch}")
[ -n "${TRACE}" ] && echo "${change_info}"

echo "Waiting for change batch to become in sync..."
change_id=$(echo "${change_info}" | jq -M -r .ChangeInfo.Id)
[ -n "${TRACE}" ] && echo "Change ID: ${change_id}"

for attempt in $(seq 1 120); do
    echo "Attempt ${attempt}..."
    change_info=$(aws route53 get-change --id "${change_id}")
    [ -n "${TRACE}" ] && echo "${change_info}"
    change_status=$(echo "${change_info}" | jq -M -r .ChangeInfo.Status)
    [ -n "${TRACE}" ] && echo "Change status: ${change_status}"

    if [ "${change_status}" == "INSYNC" ]; then
        echo "In sync. Done."
        break
    fi

    echo "Still out of sync. Continuing."
    sleep 5
done
