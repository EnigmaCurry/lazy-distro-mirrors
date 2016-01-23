# Lazy Distro Mirrors

I have a pretty slow internet connection. I don't run a computer lab.
I don't have users. But, I do have multiple machines running various
distros of Linux. If I update them, they tend to download a lot of
redundant data, which is taxing on my connection. I could run a local
mirror of the Arch and Debian repositories I use, but that seems like
overkill. Really what I want is to just be able to cache files that I
download once so that I don't have to re-download them a second time.
This is the job for a caching proxy server, like squid. Except, HTTP
proxies are a pain to setup, especially with package managers. I want
something that just works.

Lazy Distro Mirrors is a docker container that hosts a *reverse* squid
proxy. This is effectively a local mirror of a remote website (like
http://mirrors.kernel.org), with transparent caching. This is not a
full mirror, but it looks and behaves like one. When you download a
file for the first time, it goes to the remote mirror to fetch it.
Subsequent retrievals will fetch it from the local cache. It will do
this until you fill up the cache (20GB by default) and then it will
start deleting the least recently used file.

The benefit of a reverse proxy is that you don't have to configure an
HTTP proxy, instead you edit the package manager configuration to use
a local URL for the mirror to use. The hard configuration is done once,
on one computer, and then all the rest of the computers on your LAN
get to use it by just choosing the correct mirror URL.

Thank you to [Matt Wagner and his blog post](http://ma.ttwagner.com/lazy-distro-mirrors-with-squid/). 
I copied most of his squid configuration for this. I also copied 
the name he used, as I couldn't think of anything better. Being lazy 
seemed appropriate.

## Usage

You need docker, install it however you like. [Here's the official docs
for that](https://docs.docker.com/linux/).

You'll need two directories, one to place the config file, and one for
the squid cache directory. For example:

    mkdir -p /opt/docker/lazy-distro-mirrors/config
    mkdir -p /opt/docker/lazy-distro-mirrors/cache

Download and start the docker container:

    docker run \
    --name lazy-distro-mirrors \
    -d --restart=always \ 
    --publish 8080:8080 \
    --volume /opt/docker/lazy-distro-mirrors/config:/docker_configurator/ \
    --volume /opt/docker/lazy-distro-mirrors/cache:/var/spool/squid3 \
    enigmacurry/lazy-distro-mirrors

Replace with the directory names you chose. Replace the first `8080`
with the port you want the proxy to run on.

By now the proxy should be running on the port you chose.

On first running the container, it will have written it's config file
to the config directory you specified. Open up config.yaml in that
location.

You'll see some settings you may want to edit:

    mirrors:
     kernel-mirror: http://mirrors.kernel.org
     xmission-mirror: http://mirrors.xmission.com
     advancedhosters-mirror: http://mirrors.advancedhosters.com

These are the three default mirrors I use, but you can add your own
here. Each mirror has a name and a URL. Just edit the file, save it,
and restart the container:

    docker restart lazy-distro-mirrors

Finally, Squid relies upon name-based resolution to pick the mirror
you're using. For instance, to use the kernel.org mirror, you'll need
to go to http://kernel-mirror:8080/ - this is the local URL for that
mirror. If you have a DNS server running on your router, add the IP 
address of your server running docker and assign it the name `kernel-mirror`. 
If you don't run your own DNS server (I highly recommend [dd-wrt with 
dnsmasq](http://cybernetnews.com/local-internal-dns-ddwrt/)), you can
also just add it to your /etc/hosts file, but you'll have to do this 
on each machine you want to use it with:

    127.0.0.1      kernel-mirror xmission-mirror advancedhosters-mirror

Do the same for all mirrors you define.

Now you can switch between mirrors by going to the different local
URLs:

    http://kernel-mirror:8080/
    http://xmission-mirror:8080/
    http://advancedhosters-mirror:8080/

## Package manager configuration

In order to get your distro to use this for package updates, you'll
need to select the local URL as your primary mirror location. Consult
your distribution's documentation for how best to do that. Here's how
to do it briefly:

For Arch Linux, edit /etc/pacman.d/mirrorlist, put this at the top:

    Server = http://kernel-mirror:8080/archlinux/$repo/os/$arch

If you want to force using this mirror, delete everything else in the
file. 

For anything using apt-get, edit /etc/apt/sources.list and replace the
domain with your local one. For example:

    deb http://us.archive.ubuntu.com/ubuntu/ trusty main restricted

Becomes:

    deb http://kernel-mirror:8080/ubuntu/ trusty main restricted

    
