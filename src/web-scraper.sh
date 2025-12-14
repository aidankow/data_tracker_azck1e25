#!/bin/bash

set -e

#exit codes:
UNEXPECTED_ERROR=99
SCRAPE_FAIL=100
MISSING_FILE=101

trap 'echo "(ERROR) Script failed at line $LINENO" >&2; exit $UNEXPECTED_ERROR' ERR

function scrape_website {
    URL='https://www.klsescreener.com/v2/markets'
    ALLSTOCKS_FILE="../textfiles/stocks.txt"
    MARKETS_FILE="../textfiles/markets.txt"
    PRICES_FILE="../textfiles/prices.txt"
    TIME_TEMP="../textfiles/time.tmp"

    MAX_ATTEMPTS=10
    attempts=0

    while [ $attempts -lt $MAX_ATTEMPTS ]; do
        curl -fsS -o "$ALLSTOCKS_FILE" "$URL" || {
            echo "(ERROR) curl failed in attempt $((attempts+1))" >&2
            attempts=$((attempts+1))
            sleep 1
            continue
        }

        grep -Eo '<a href="/v2/markets/intraday/[^"]+">[^"]+</a>' "$ALLSTOCKS_FILE" \
        | sed -E 's/.*>(.*)<.*/\1/' > "$MARKETS_FILE"
        grep -Eo 'class="col-md-4" data-code="[^"]+" data-ref-price="[^"]+" data-price="[^"]+"' "$ALLSTOCKS_FILE" \
        | sed -E 's/.*data-price="([^"]+)"/\1/' > "$PRICES_FILE"

        if [ -s "$ALLSTOCKS_FILE" ] && [ -s "$MARKETS_FILE" ] && [ -s "$PRICES_FILE" ]; then
            return 0
        fi
        echo "(ERROR) files empty in attempt $((attempts+1))" >&2
        attempts=$((attempts+1))
        sleep 1
    done
    return 1
}

function clean_prices {
    NUM_MARKETS=$(wc -l < "$MARKETS_FILE")
    head -n "$NUM_MARKETS" "$PRICES_FILE" > "${PRICES_FILE}.tmp"
    mv "${PRICES_FILE}.tmp" "$PRICES_FILE"

    awk 'NR <= 30 { printf("%.2f\n", $1); next } NR >= 31 && NR <= 44 { printf("%.4f\n", $1); next }' < "$PRICES_FILE" > \
    "${PRICES_FILE}.tmp"
    mv "${PRICES_FILE}.tmp" "$PRICES_FILE"
}

function get_date {
    DATE=$(date +"%Y-%m-%d")
    TIME=$(date +"%H:%M:%S")
    DATETIME="$DATE $TIME"

    NUM_MARKETS=$(wc -l < "$MARKETS_FILE")
    yes "$DATETIME","$TIME" | head -n "$NUM_MARKETS" > "$TIME_TEMP"
}

function format_data {
    clean_prices
    get_date
    
    CLEANED_DATA="../textfiles/cleaned_data.csv"
    MARKET_IDS="../textfiles/marketIDs.txt"
    FILTER="../textfiles/marketNames.txt"

    for f in "$MARKETS_FILE" "$PRICES_FILE" "$MARKET_IDS" "$FILTER"; do
        if [ ! -s "$f" ]; then
            echo "(ERROR) Missing or empty file: $f" >&2
            exit $MISSING_FILE
        fi
    done

    paste -d "," "$MARKETS_FILE" "$PRICES_FILE" "$TIME_TEMP" | grep -Ff "$FILTER" > "$CLEANED_DATA"
    rm "$TIME_TEMP"

    paste -d "," "$MARKET_IDS" "$CLEANED_DATA" > "$CLEANED_DATA.tmp"
    mv "$CLEANED_DATA.tmp" "$CLEANED_DATA"
}

if ! scrape_website; then
    echo "(ERROR) Failed to scrape website." >&2
    exit $SCRAPE_FAIL
fi
format_data