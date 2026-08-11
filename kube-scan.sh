#!/bin/bash

# kubesec-scan.sh

# Using Kubesec v2 API
scan_result=$(curl -sSX POST \
  --data-binary @k8s_deployment_service.yaml \
  https://v2.kubesec.io/scan)

scan_message=$(echo "$scan_result" | jq -r '.[0].message')
scan_score=$(echo "$scan_result" | jq -r '.[0].score')

# Kubesec scan result processing
echo "Scan Score: $scan_score"
echo "Kubesec Message: $scan_message"

if [[ "$scan_score" -ge 5 ]]; then
    echo "Score is $scan_score"
    echo "Kubesec Scan: $scan_message"
else
    echo "Score is $scan_score, which is less than 5."
    echo "Scanning Kubernetes Resource has Failed"
    exit 1
fi
