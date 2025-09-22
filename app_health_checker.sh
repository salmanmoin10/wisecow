#!/bin/bash


URL=${1:-"https://127.0.0.1:8443/"}
if [ -z "$1" ]; then
  echo "Usage: $0 <URL> (default: $URL)"
fi

TPS
STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" -H "Host: localhost" "$URL")

if [ "$STATUS" = "200" ] || [ "$STATUS" = "301" ] || [ "$STATUS" = "302" ]; then
  echo "Application is UP (Status: $STATUS)"
else
  echo "Application is DOWN (Status: $STATUS)"
fi