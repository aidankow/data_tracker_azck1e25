#!/bin/bash
curl -o bitcoin.txt 'https://coinmarketcap.com/currencies/bitcoin/'
grep -o '\$[0-9,]\+\.[0-9]\+' bitcoin.txt | head -n 1