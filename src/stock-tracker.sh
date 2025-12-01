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

    paste -d "," "$MARKETS_FILE" "$PRICES_FILE" > "$NEW_FILE"
}

if scrape_website; then
    match_data
else
    echo "(ERROR) Failed to scrape website."
    exit 1
fi

#class="col-md-4" data-code="200" data-ref-price="1617.46" data-price="1604.47"
#<a href="/v2/markets/intraday/KLSE">FTSE Bursa Malaysia KLCI</a>

#class="col-md-4" data-code="CPO" data-ref-price="3990" data-price="4022.5"
#<a href="/v2/markets/intraday/CPO">Crude Palm Oil</a>

# class="col-md-4" data-code="SGDMYR=X" data-ref-price="3.1888000633" data-price="3.1877"
# <a href="/v2/markets/intraday/SGDMYR%3DX">SGD/MYR</a>

# class="col-md-4" data-code="USDMYR=X" data-ref-price="4.1299999275" data-price="4.129"
# <a href="/v2/markets/intraday/USDMYR%3DX">USD/MYR</a>

# class="col-md-4" data-code="CNYMYR=X" data-ref-price="0.58405000603" data-price="0.58387"
# <a href="/v2/markets/intraday/CNYMYR%3DX">CNY/MYR</a>

# class="col-md-4" data-code="GBPMYR=X" data-ref-price="5.4703003075" data-price="5.4627"
# <a href="/v2/markets/intraday/GBPMYR%3DX">GBP/MYR</a>

# class="col-md-4" data-code="HKDMYR=X" data-ref-price="0.53070000904" data-price="0.53043"
# <a href="/v2/markets/intraday/HKDMYR%3DX">HKD/MYR</a>

# class="col-md-4" data-code="TWDMYR=X" data-ref-price="13.100000339000001" data-price="13.08"
# <a href="/v2/markets/intraday/TWDMYR%3DX">100 TWD/MYR</a>

# class="col-md-4" data-code="JPYMYR=X" data-ref-price="2.641999885" data-price="2.651"
# <a href="/v2/markets/intraday/JPYMYR%3DX">100 JPY/MYR</a>

# class="col-md-4" data-code="NZDMYR=X" data-ref-price="2.3699000904" data-price="2.3672"
# <a href="/v2/markets/intraday/NZDMYR%3DX">NZD/MYR</a>

# class="col-md-4" data-code="AUDMYR=X" data-ref-price="2.7060999184" data-price="2.703"
# <a href="/v2/markets/intraday/AUDMYR%3DX">AUD/MYR</a>

# class="col-md-4" data-code="EURMYR=X" data-ref-price="4.7934999817" data-price="4.7893"
# <a href="/v2/markets/intraday/EURMYR%3DX">EUR/MYR</a>

# class="col-md-4" data-code="CADMYR=X" data-ref-price="2.9523999214" data-price="2.95"
# <a href="/v2/markets/intraday/CADMYR%3DX">CAD/MYR</a>

# class="col-md-4" data-code="CHFMYR=X" data-ref-price="5.1436001778" data-price="5.1375"
# <a href="/v2/markets/intraday/CHFMYR%3DX">CHF/MYR</a>