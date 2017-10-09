#!/bin/sh
echo "extracting from CSV files"
./pre_process_rain.sh
echo "processing on IDL®"
idl -e '.r process_rain.pro'
