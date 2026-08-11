response=$(curl -s "$applicationURL:$PORT$applicationURI" | tr -d '\r\n')
http_code=$(curl -s -o /dev/null -w "%{http_code}" "$applicationURL:$PORT$applicationURI")

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
