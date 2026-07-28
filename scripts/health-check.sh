#!/bin/bash

URL=http://localhost

STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL)

if [ "$STATUS" = "200" ]
then
    echo "Application is Healthy"
    exit 0
else
    echo "Application Failed"
    exit 1
fi
