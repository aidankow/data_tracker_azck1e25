#!/bin/bash
XAMPP_BIN="/Applications/XAMPP/xamppfiles/bin"

echo "Starting Apache..."
sudo "$XAMPP_BIN/apachectl" start

echo "Starting MySQL..."
sudo "$XAMPP_BIN/mysql.server" start