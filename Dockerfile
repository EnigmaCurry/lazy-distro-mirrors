FROM sameersbn/squid
MAINTAINER ryan@enigmacurry.com

RUN apt-get update && apt-get install -y python3 python3-yaml python3-mako

ADD config /docker_configurator
ADD https://raw.githubusercontent.com/EnigmaCurry/docker-configurator/master/docker_configurator.py /docker_configurator/docker_configurator.py
ADD scripts/start.sh /

EXPOSE 8080/tcp
VOLUME ["/var/spool/squid3"]

ENTRYPOINT ["/start.sh"]
