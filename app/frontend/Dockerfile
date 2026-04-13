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
# Put our entrypoint under a unique name — the nginx base image sets
# ENTRYPOINT=/docker-entrypoint.sh by default, which would otherwise
# clobber our wrapper script.
COPY docker-entrypoint.sh /cloudrun-entrypoint.sh
RUN sed -i 's/\r$//' /cloudrun-entrypoint.sh && chmod +x /cloudrun-entrypoint.sh

ENV PORT=8080
EXPOSE 8080

# Reset ENTRYPOINT so the nginx base image's default doesn't fire first,
# then invoke our script via sh to bypass any shebang/format quirks.
ENTRYPOINT []
CMD ["sh", "/cloudrun-entrypoint.sh"]
