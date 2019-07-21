#Kudos to http://ma.ttwagner.com/lazy-distro-mirrors-with-squid/ most
#of the parameters here were taken from that.

http_access allow all
http_port 8080 accel defaultsite=kernel-mirror vhost

# This needs to be specified before the cache_dir, otherwise it's ignored ?!
maximum_object_size 4096 MB

# Cache settings
cache_dir ufs /var/spool/squid ${cache_size} 16 256

cache_replacement_policy heap LFUDA

refresh_pattern -i .rpm$ 129600 100% 129600 refresh-ims override-expire
refresh_pattern -i .iso$ 129600 100% 129600 refresh-ims override-expire
refresh_pattern -i .deb$ 129600 100% 129600 refresh-ims override-expire
refresh_pattern -i .tar.xz$ 129600 100% 129600 refresh-ims override-expire
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320

% for mirror, url in mirrors.items():
  <%
    import urllib
    url_parsed = urllib.parse.urlparse(url)
    hostname = url_parsed.hostname
    port = url_parsed.port
    if port is None:
        port = 80
  %>
cache_peer ${hostname} parent ${port} 0 no-query originserver name=${mirror}
cache_peer_domain ${mirror} ${mirror}
% endfor
