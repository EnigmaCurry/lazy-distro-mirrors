FROM sameersbn/squid
MAINTAINER ryan@enigmacurry.com

COPY squid.conf /etc/squid3/squid.conf

EXPOSE 8080/tcp
VOLUME ["/var/spool/squid3"]
ENTRYPOINT ["/sbin/entrypoint.sh"]

