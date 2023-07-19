#!/bin/sh
set -e

# Compute the DNS resolvers for use in the templates - if the IP contains ":", it's IPv6 and must be enclosed in []
export RESOLVERS=$(awk '$1 == "nameserver" {print ($2 ~ ":")? "["$2"]": $2}' ORS=' ' /etc/resolv.conf | sed 's/ *$//g')
if [ "x$RESOLVERS" = "x" ]; then
    echo "Error: there is no resolvers!!" >&2
    exit 1
fi

cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.template

proxy_send_timeout="${proxy_send_timeout:-60s}"
proxy_read_timeout="${proxy_read_timeout:-60s}"
envsubst '$RESOLVERS $UPSTREAM_HTTP_ADDRESS $CLIENT_MAX_BODY_SIZE $proxy_read_timeout $proxy_send_timeout' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

exec "$@"
