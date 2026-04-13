#!/bin/sh
set -eu

: "${PORT:=8080}"
: "${BACKEND_URL:=http://backend:8000}"

export PORT BACKEND_URL

# Render nginx.conf from the template, substituting only the variables we use.
envsubst '${PORT} ${BACKEND_URL}' \
    < /etc/nginx/conf.d/default.conf.template \
    > /etc/nginx/conf.d/default.conf

exec nginx -g 'daemon off;'
