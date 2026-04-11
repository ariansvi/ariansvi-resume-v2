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

COPY --from=builder /src/public /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost/health || exit 1
