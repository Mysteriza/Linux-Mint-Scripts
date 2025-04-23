#!/bin/bash

# Script to test proxies from proxychains4.conf with enhanced features
# Features:
# - Check proxy status (active/dead) with colored output
# - Fetch geolocation (country, city, ISP) using ip-api.com
# - Measure latency for each proxy
# - Display results in a clean, line-based format with separators
# - Optimized for speed with caching and minimal overhead

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Path to proxychains config
PROXY_CONF="/etc/proxychains4.conf"

# Test URL for geolocation
GEO_URL="http://ip-api.com/json"
# Test URL for latency (Cloudflare for reliability)
LATENCY_URL="1.1.1.1"

# Temporary file for proxychains config
TEMP_CONF="/tmp/temp_proxychains.conf"

# Cache file for geolocation (to avoid repeated API calls)
GEO_CACHE="/tmp/geo_cache.json"

# Arrays to store results
declare -A LATENCIES
declare -A GEO_INFO

# Function to measure latency (optimized: 2 pings, timeout 2s)
measure_latency() {
    local proxy_conf="$1"
    local result
    # Run ping through proxychains, capture average latency
    result=$(proxychains4 -q -f "$proxy_conf" ping -c 2 -W 2 "$LATENCY_URL" 2>/dev/null | grep 'avg' | awk -F'/' '{print $5}')
    echo "${result:-N/A}"
}

# Function to fetch geolocation with caching
fetch_geolocation() {
    local proxy_conf="$1"
    local ip="$2"
    local cache_key="$ip"
    local response country city isp

    # Check cache
    if [ -f "$GEO_CACHE" ] && jq -e ".\"$cache_key\"" "$GEO_CACHE" > /dev/null 2>&1; then
        response=$(jq -r ".\"$cache_key\"" "$GEO_CACHE")
    else
        # Fetch from ip-api.com
        response=$(proxychains4 -q -f "$proxy_conf" curl -s -m 5 "$GEO_URL")
        # Cache result
        if [ -n "$response" ]; then
            jq -n --arg key "$cache_key" --argjson val "$response" '{($key): $val}' >> "$GEO_CACHE"
        fi
    fi

    # Parse response
    if [ -n "$response" ]; then
        country=$(echo "$response" | jq -r '.country // "Unknown"')
        city=$(echo "$response" | jq -r '.city // "Unknown"')
        isp=$(echo "$response" | jq -r '.isp // "Unknown"')
        echo "$country|$city|$isp"
    else
        echo "Unknown|Unknown|Unknown"
    fi
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required for JSON parsing. Install it with: sudo apt install jq${NC}"
    exit 1
fi

# Initialize cache file
: > "$GEO_CACHE"

# Extract proxies (socks5 only, skip comments and invalid lines)
PROXIES=$(grep -E '^socks5[[:space:]]+[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$PROXY_CONF" | grep -v '^#' | awk '{print $1, $2, $3, $4, $5}')

# Check if proxies exist
if [ -z "$PROXIES" ]; then
    echo -e "${RED}Error: No valid socks5 proxies found in $PROXY_CONF${NC}"
    exit 1
fi

echo -e "${BLUE}Testing proxies from $PROXY_CONF...${NC}"

# Test each proxy
while IFS= read -r line; do
    [ -z "$line" ] && continue

    PROTOCOL=$(echo "$line" | awk '{print $1}')
    IP=$(echo "$line" | awk '{print $2}')
    PORT=$(echo "$line" | awk '{print $3}')
    USER=$(echo "$line" | awk '{print $4}')
    PASS=$(echo "$line" | awk '{print $5}')

    # Build proxy line
    PROXY_LINE="$PROTOCOL $IP $PORT $USER $PASS"
    PROXY_KEY="$IP:$PORT"

    # Write temporary config
    echo "[ProxyList]" > "$TEMP_CONF"
    echo "$PROXY_LINE" >> "$TEMP_CONF"

    # Test connectivity
    if proxychains4 -q -f "$TEMP_CONF" curl -s -m 5 "$GEO_URL" > /dev/null; then
        STATUS="${GREEN}ACTIVE${NC}"
        
        # Measure latency
        LATENCY=$(measure_latency "$TEMP_CONF")
        LATENCIES["$PROXY_KEY"]="$LATENCY"

        # Fetch geolocation
        GEO=$(fetch_geolocation "$TEMP_CONF" "$IP")
        IFS='|' read -r COUNTRY CITY ISP <<< "$GEO"
        GEO_INFO["$PROXY_KEY"]="$COUNTRY, $CITY, $ISP"
    else
        STATUS="${RED}DEAD${NC}"
        LATENCIES["$PROXY_KEY"]="N/A"
        GEO_INFO["$PROXY_KEY"]="Unknown, Unknown, Unknown"
        COUNTRY="Unknown"
        CITY="Unknown"
        ISP="Unknown"
        LATENCY="N/A"
    fi

    # Print proxy info in a clean, line-based format
    echo -e "Proxy: $PROXY_KEY"
    echo -e "Status: $STATUS"
    echo -e "Country: ${COUNTRY:-Unknown}"
    echo -e "City: ${CITY:-Unknown}"
    echo -e "ISP: ${ISP:-Unknown}"
    echo -e "Latency: $LATENCY ms"
    echo -e "${BLUE}---${NC}"
done <<< "$PROXIES"

# Clean up
rm -f "$TEMP_CONF" "$GEO_CACHE"

# Find fastest proxy
FASTEST_PROXY=""
FASTEST_LATENCY=999999
for proxy in "${!LATENCIES[@]}"; do
    LATENCY="${LATENCIES[$proxy]}"
    if [[ "$LATENCY" != "N/A" && $(echo "$LATENCY < $FASTEST_LATENCY" | bc -l) -eq 1 ]]; then
        FASTEST_LATENCY="$LATENCY"
        FASTEST_PROXY="$proxy"
    fi
done

# Print fastest proxy
if [ -n "$FASTEST_PROXY" ]; then
    echo -e "${GREEN}Fastest Proxy: $FASTEST_PROXY (Latency: $FASTEST_LATENCY ms, "${GEO_INFO[$FASTEST_PROXY]}")${NC}"
else
    echo -e "${RED}Fastest Proxy: None (all proxies dead)${NC}"
fi

echo -e "${BLUE}Done!${NC}"