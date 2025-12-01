#!/bin/bash
curl -o src/stocks.txt 'https://www.klsescreener.com/v2/markets' | grep -oE 'class="col-md-4" data-code="[^"]+" data-ref-price="[^"]+" data-price="[^"]+"' src/stocks.txt
grep -oE 'class="col-md-4" data-code="[^"]+" data-ref-price="[^"]+" data-price="[^"]+"' src/stocks.txt > src/prices.txt
grep -oE '<a href="/v2/markets/intraday/[^"]+">[^"]+</a>' src/stocks.txt > src/markets.txt