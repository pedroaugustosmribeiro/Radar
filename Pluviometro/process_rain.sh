#!/bin/sh
./pre_process_rain.sh
idl -e '.r process_rain.pro'
