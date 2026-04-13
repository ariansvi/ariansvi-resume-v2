FROM hugomods/hugo:go-0.139.0 AS builder

ARG HUGO_BASEURL=""
WORKDIR /src
COPY . .

RUN if [ -n "$HUGO_BASEURL" ]; then \
      hugo --minify --baseURL "$HUGO_BASEURL"; \
    else \
      hugo --minify; \
    fi

FROM nginx:1.27-alpine

LABEL maintainer="Arian Svirsky <arian@ariansvi.com>"
LABEL description="Arian Svirsky Resume - Frontend"

# envsubst is part of gettext; needed to template nginx.conf at runtime
RUN apk add --no-cache gettext

COPY --from=builder /src/public /usr/share/nginx/html
COPY nginx.conf.template /etc/nginx/conf.d/default.conf.template
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
