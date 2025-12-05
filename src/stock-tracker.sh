#!/bin/bash
function scrape_website {
    URL='https://www.klsescreener.com/v2/markets'
    ALLSTOCKS_FILE="../textfiles/stocks.txt"
    MARKETS_FILE="../textfiles/markets.txt"
    PRICES_FILE="../textfiles/prices.txt"
    TIME_TEMP="../textfiles/time.tmp"

    MAX_ATTEMPTS=10
    attempts=0
    success=0

    while [ $success -ne 1 ] && [ $attempts -ne $MAX_ATTEMPTS ]; do
        curl -o "$ALLSTOCKS_FILE" "$URL"
        grep -Eo '<a href="/v2/markets/intraday/[^"]+">[^"]+</a>' "$ALLSTOCKS_FILE" \
        | sed -E 's/.*>(.*)<.*/\1/' > "$MARKETS_FILE"
        grep -Eo 'class="col-md-4" data-code="[^"]+" data-ref-price="[^"]+" data-price="[^"]+"' "$ALLSTOCKS_FILE" \
        | sed -E 's/.*data-price="([^"]+)"/\1/' > "$PRICES_FILE"

        if [ -f "$ALLSTOCKS_FILE" ] && [ -f "$MARKETS_FILE" ] && [ -f "$PRICES_FILE" ]; then
            success=1
            break
        fi
        attempts=$((attempts+1))
    done

    if [ $success -ne 1 ]; then
        return 1
    fi
    return 0
}

function clean_prices {
    NUM_MARKETS=$(wc -l < "$MARKETS_FILE")
    head -n "$NUM_MARKETS" "$PRICES_FILE" > "${PRICES_FILE}.tmp"
    mv "${PRICES_FILE}.tmp" "$PRICES_FILE"

    awk 'NR <= 30 { printf("%.2f\n", $1); next } NR >= 31 && NR <= 44 { printf("%.4f\n", $1); next }' < "$PRICES_FILE" > "${PRICES_FILE}.tmp"
    mv "${PRICES_FILE}.tmp" "$PRICES_FILE"
}

function get_date {
    DATE=$(date +"%Y-%m-%d")
    TIME=$(date +"%H:%M:%S")
    DATETIME="$DATE $TIME"

    NUM_MARKETS=$(wc -l < "$MARKETS_FILE")
    yes "$DATETIME" | head -n "$NUM_MARKETS" > "$TIME_TEMP"
}

function format_data {
    clean_prices
    get_date
    
    CLEANED_DATA="../textfiles/cleaned_data.csv"
    MARKET_IDS="../textfiles/marketIDs.txt"
    FILTER="../textfiles/marketNames.txt"
    paste -d "," "$MARKETS_FILE" "$PRICES_FILE" "$TIME_TEMP" | grep -Ff "$FILTER" > "$CLEANED_DATA"
    rm $TIME_TEMP

    paste -d "," "$MARKET_IDS" "$CLEANED_DATA" > "$CLEANED_DATA.tmp"
    mv "$CLEANED_DATA.tmp" "$CLEANED_DATA"
}

if scrape_website; then
    format_data
else
    echo "(ERROR) Failed to scrape website."
    exit 1
fi