#!/bin/bash
# usage: set_key_flag.sh <key> <0|1>
echo "$2" > "/tmp/${1}_flag"
