#!/bin/bash

sleep 10

PORT=$(kubectl -n default get svc "$serviceName" -o json | jq -r '.spec.ports[0].nodePort')

echo "PORT: $PORT"
echo "URL: $applicationURL:$PORT/$applicationURI"

if [[ -n "$PORT" ]]; then

    result=$(curl -s -w "\n%{http_code}" \
        "$applicationURL:$PORT$applicationURI")

    response=$(echo "$result" | head -n1)
    http_code=$(echo "$result" | tail -n1)

    echo "Response: [$response]"
    echo "HTTP Code: [$http_code]"

    if [[ "$response" == "100" ]]; then
        echo "Increment Test Passed"
    else
        echo "Increment Test Failed"
        exit 1
    fi

    if [[ "$http_code" == "200" ]]; then
        echo "HTTP Status Code Test Passed"
    else
        echo "HTTP Status code is not 200"
        exit 1
    fi

else
    echo "The Service does not have a NodePort"
    exit 1
fi
