#!/bin/zsh

CONTAINER_NAME="charming_aryabhata"

echo "--- Honeygain Container Status ---"
docker ps -a --filter name=$CONTAINER_NAME --format "table {{.Names}}\t{{.Status}}\t{{.ID}}"

echo $'\n--- Last 50 Log Lines ---'
docker logs $CONTAINER_NAME --tail 50 --timestamps 2>&1 | while read -r timestamp message; do
    formatted_date=$(date -d "$timestamp" "+%Y-%m-%d %H:%M:%S")
    echo "$formatted_date | $message"
done

echo $'\nPress Enter to close this window...'
read -r