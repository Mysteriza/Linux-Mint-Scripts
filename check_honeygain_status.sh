#!/bin/zsh

CONTAINER_NAME=""

echo "--- Honeygain Container Status ---"
docker ps -a --filter name=$CONTAINER_NAME --format "table {{.Names}}\t{{.Status}}\t{{.ID}}"

echo $'\n--- Last 5 Log Lines (WIB) ---'
docker logs $CONTAINER_NAME --tail 5 --timestamps 2>&1 | while read -r timestamp message; do
    formatted_date=$(date -d "$timestamp" "+%Y-%m-%d %H:%M:%S")
    echo "$formatted_date | $message"
done

echo $'\nPress Enter to close this window...'
read -r