#!/usr/bin/env bash
# Run all install scripts in order

echo "=== Running Packages Scripts ===" && bash ./auto.sh packages
echo "=== Running System Scripts ===" && bash ./auto.sh system
echo "=== Running User Scripts ===" && bash ./auto.sh user