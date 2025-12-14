#!/bin/bash

set -e

#exit codes:
UNEXPECTED_ERROR=99
MYSQL_FAIL=100
MISSING_FILE=101

trap 'echo "(ERROR) Script failed at line $LINENO" >&2; exit $UNEXPECTED_ERROR' ERR

MYSQL="/Applications/XAMPP/xamppfiles/bin/mysql"
if [ ! -x "$MYSQL" ]; then
    echo "(ERROR) MySQL client not found or not executable: $MYSQL" >&2
    exit $MYSQL_FAIL
fi

function fetch_plots_for {
    $MYSQL -u root my_market_tracker <<EOF | tail -n +2 > "$2"
    SELECT Timestamp, Price FROM $1 ORDER BY Timestamp;
EOF
}

function create_graph_for {
    gnuplot <<EOF
        set datafile separator tab
        set xdata time
        set timefmt "%Y-%m-%d %H:%M:%S"
        set term pngcairo font "Times-New-Roman,12" size 1200,800
        set output "$1"
        set grid
        set key outside
        set title "$3"
        set xlabel "Timestamp"
        set ylabel "Price"
        set format x "%y-%m-%d\n%H:%M"
        plot "$2" using 1:2 with lines linewidth 2 title "Price"
EOF
}

function iterate_markets {
    MARKETS_FILE="../textfiles/marketIDs.txt"
    if [ ! -s "$MARKETS_FILE" ]; then
        echo "(ERROR) Missing or empty file: $MARKETS_FILE" >&2
        exit $MISSING_FILE
    fi

    while IFS= read -r MarketID; do
        OUTPUT_FILE="../plots/$MarketID.dat"
        GRAPH_NAME=$($MYSQL -u root -N my_market_tracker -e "SELECT GraphID FROM markets WHERE MarketID='$MarketID';")
        GRAPH_FILE="../graphs/$GRAPH_NAME"
        MarketName=$($MYSQL -u root -N my_market_tracker -e "SELECT MarketName FROM markets WHERE MarketID='$MarketID';")

        fetch_plots_for "$MarketID" "$OUTPUT_FILE"
        if [ ! -s "$OUTPUT_FILE" ]; then
            echo "(ERROR) Missing or empty file: $OUTPUT_FILE" >&2
            exit $MISSING_FILE
        fi

        create_graph_for "$GRAPH_FILE" "$OUTPUT_FILE" "$MarketName"
        if [ ! -s "$GRAPH_FILE" ]; then
            echo "(ERROR) Missing or empty file: $GRAPH_FILE" >&2
            exit $MISSING_FILE
        fi
    done < $MARKETS_FILE
}

iterate_markets