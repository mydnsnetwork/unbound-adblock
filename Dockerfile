FROM alpine:latest

RUN apk update \
	&& apk --no-cache add \
	bash \
	supervisor \
	unbound \
	openssl \
	&& rm -rf /etc/unbound/unbound.conf /etc/unbound/root.hints \
	&& mkdir -p /etc/unbound/blocked

COPY scripts/ /scripts
COPY unbound.conf /etc/unbound/unbound.conf
COPY supervisor-unbound.ini /etc/supervisor.d/supervisor-unbound.ini
COPY docker-entrypoint /docker-entrypoint

RUN chmod u+x /docker-entrypoint /scripts/*

ENTRYPOINT ["/docker-entrypoint"]
CMD [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf" ]

# Healthcheck
HEALTHCHECK --interval=1m --timeout=30s --start-period=10s CMD drill @127.0.0.1 example.com || exit 1