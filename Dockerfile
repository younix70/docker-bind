FROM debian:stretch-slim

RUN apt-get update && apt-get install --no-install-recommends -y \
    bash \
    bind9 \
    wget \
    automake \
    make \
    gcc \
    build-essential \
    libunbound-dev \
    libldns-dev \
    autoconf \
    libevent-dev \
    libuv1-dev \
    libev-dev \
    libssl-dev \
    libidn11-dev \
    libyaml-dev \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN set -x && \
    mkdir -p /tmp/src/getdns && \
    cd /tmp/src/getdns && \
    wget -O getdns.tar.gz https://getdnsapi.net/releases/getdns-1-2-0/getdns-1.2.0.tar.gz && \
    tar xzf getdns.tar.gz && \
    rm -f getdns.tar.gz && \
    cd getdns-1.2.0 && \
    groupadd getdns && \
    useradd -g getdns -s /etc -d /dev/null getdns && \
    ./configure --prefix=/opt/getdns --with-stubby --build=x86_64 --host=x86_64 --target=x86_64 &&\
    make && \
    make install && \
    rm -rf /tmp/* && \
    mkdir -p /opt/getdns/var/run/ && \
    chown getdns:getdns /opt/getdns/var/run/

COPY stubby.yml /opt/getdns/etc/stubby/stubby.yml
COPY named.conf.options /etc/bind/named.conf.options
COPY named.conf.local /etc/bind/named.conf.local
COPY for.larsdebruin.loc /etc/bind/for.larsdebruin.loc

EXPOSE 53/UDP

COPY entrypoint.sh /opt/
RUN chmod 777 /opt/entrypoint.sh

CMD ["/bin/bash","/opt/entrypoint.sh"]