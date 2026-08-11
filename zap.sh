#!/bin/bash

set -u

PORT=$(kubectl -n default get svc "${serviceName}" -o json | jq -r '.spec.ports[].nodePort')

echo "PORT: $PORT"
echo "URL: ${applicationURL}:${PORT}/v3/api-docs"

mkdir -p owasp-zap-report

docker run --rm \
  -v "$(pwd):/zap/wrk/:rw" \
  -t ghcr.io/zaproxy/zaproxy:stable \
  zap-api-scan.py \
  -t "${applicationURL}:${PORT}/v3/api-docs" \
  -f openapi \
  -r zap_report.html

exit_code=$?

if [ -f zap_report.html ]; then
    mv zap_report.html owasp-zap-report/
fi

echo "Exit Code : $exit_code"

if [ "$exit_code" -ne 0 ]; then
    echo "OWASP ZAP Report has either Low/Medium/High Risk. Please check the HTML Report"
    exit 1
else
    echo "OWASP ZAP did not report any Risk"
fi
