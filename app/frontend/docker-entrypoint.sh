#!/bin/sh
set -eu

: "${PORT:=8080}"
: "${BACKEND_URL:=http://backend:8000}"
: "${INTERNAL_TOKEN:=dev-token}"

export PORT BACKEND_URL INTERNAL_TOKEN

# Render nginx.conf from the template, substituting only the variables we use.
envsubst '${PORT} ${BACKEND_URL} ${INTERNAL_TOKEN}' \
    < /etc/nginx/conf.d/default.conf.template \
    > /etc/nginx/conf.d/default.conf

exec nginx -g 'daemon off;'
