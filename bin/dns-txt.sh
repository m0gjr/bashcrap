#!/bin/bash

curl "https://www.duckdns.org/update?domains=$CERTBOT_DOMAIN&token=$(cat /etc/local/dns-token)&txt=$CERTBOT_VALIDATION"

until [ "$(host -t txt _acme-challenge.m0gjr.duckdns.org | cut -d\" -f2)" == "$CERTBOT_VALIDATION" ]
do
	sleep 10
done
