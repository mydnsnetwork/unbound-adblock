FROM alpine:latest

RUN apk add --update --no-cache \
	bash \
	supervisor \
	unbound \
	openssl \
	drill

COPY scripts/ /scripts
COPY unbound.conf /etc/unbound/unbound.conf
COPY supervisor-unbound.ini /etc/supervisor.d/supervisor-unbound.ini
COPY docker-entrypoint /docker-entrypoint

RUN chmod u+x /docker-entrypoint /scripts/*

ENTRYPOINT ["/docker-entrypoint"]
CMD [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf" ]

# Healthcheck
HEALTHCHECK --interval=1m --timeout=30s --start-period=10s CMD drill -p 10001 @127.0.0.1 example.com || exit 1