#!/bin/bash
cat $1 | jq -f main.jq --raw-input -s
