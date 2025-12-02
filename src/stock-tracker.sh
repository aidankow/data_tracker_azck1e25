#!/bin/bash
DAY=$(date +"%u")
if [ "$DAY" -ge 6 ]; then
    echo "Market Closed"
    exit 0
fi

function scrape_website {
    URL='https://www.klsescreener.com/v2/markets'
    ALLSTOCKS_FILE="textfiles/stocks.txt"
    MARKETS_FILE="textfiles/markets.txt"
    PRICES_FILE="textfiles/prices.txt"

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

function match_data {
    NEW_FILE=textfiles/cleaned_data.csv
    NUM_MARKETS=$(wc -l < "$MARKETS_FILE")
    head -n "$NUM_MARKETS" "$PRICES_FILE" > "${PRICES_FILE}.tmp"
    mv "${PRICES_FILE}.tmp" "$PRICES_FILE"

    paste -d "," "$MARKETS_FILE" "$PRICES_FILE" | grep -Ff textfiles/filter.txt > "$NEW_FILE"
}

if scrape_website; then
    match_data
else
    echo "(ERROR) Failed to scrape website."
    exit 1
fi