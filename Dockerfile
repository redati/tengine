# docker build -t misaelgomes/tengine .
# docker run -d -p 3142:3142 misaelgomes/eg_apt_cacher_ng
# acessar localhost:3142 copiar proxy correto e colar abaixo em Acquire
# docker run -d -p 80:80 misaelgomes/tengine-php74

FROM ubuntu:latest

WORKDIR /var/www/public

RUN addgroup --system --gid 101 nginx
RUN adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 101 nginx


#https://docs.docker.com/engine/examples/apt-cacher-ng/
RUN echo 'Acquire::http { Proxy "http://172.17.0.2:3142"; };' >> /etc/apt/apt.conf.d/01proxy

ENV CONFIG "\
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \        
        --user=nginx \
        --group=nginx \
        --with-libatomic \
        --with-pcre-jit \ 
        --with-jemalloc \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_stub_status_module \
        --with-http_auth_request_module \
        --with-http_xslt_module \
        --with-threads \
        --with-stream \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-stream_realip_module \
        --with-http_slice_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-compat \
        --with-file-aio \
        --with-http_v2_module \
        --with-ipv6 \
        --with-debug \
        --add-module=modules/ngx_http_upstream_check_module \
        --add-module=modules/ngx_slab_stat \
        --add-module=modules/ngx_http_user_agent_module \
        --add-module=modules/ngx_http_upstream_vnswrr_module \
        --add-module=modules/ngx_http_upstream_dynamic_module \
        --add-module=modules/ngx_http_upstream_consistent_hash_module \
        --add-module=modules/ngx_http_sysguard_module \
	--add-module=modules/ngx_http_upstream_session_sticky_module \
        --add-module=modules/ngx_devel_kit-master \
        --add-module=modules/set-misc-nginx-module-master \
        --add-module=modules/ngx_http_geoip2_module-master  \
        --add-module=modules/headers-more-nginx-module-master \
        --add-module=modules/naxsi-master/naxsi_src \
        --add-module=modules/ngx_brotli \
        --with-pcre=/usr/src/pcre-8.44 \
        --with-cc-opt='-Wp,-D_FORTIFY_SOURCE=2,-fexceptions,-DTCP_FASTOPEN=23,--param=ssp-buffer-size=4' \
        "

VOLUME ["/var/cache/apt-cacher-ng"]

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo

# add-apt-repository depend software-properties-common
RUN apt-get update && apt-get install -y software-properties-common 
RUN add-apt-repository -y ppa:maxmind/ppa 

RUN apt-get update
RUN apt-get install -y tzdata apt-utils locales
RUN apt-get install -y nginx-common libmaxminddb0 libmaxminddb-dev mmdb-bin nano gcc flex make bison build-essential pkg-config g++ libtool autoconf git 
RUN apt-get install -y libcurl4-openssl-dev libatomic-ops-dev libjemalloc-dev libxml2-dev          
RUN apt-get install -y zlib1g curl ca-certificates openssl libxslt-dev libc-dev unzip libgeoip-dev zlib1g-dev         
RUN apt-get install -y automake autotools-dev libjemalloc2 libssl-dev  
RUN apt-get upgrade -y 

#DONLOAD
#ENV TENGINE_VERSION=master
#RUN mkdir -p /usr/src \
#        && cd /usr/src \
#        && curl -L "https://github.com/alibaba/tengine/archive/master.zip" -o tengine.zip \
#        && unzip  tengine.zip \
#        && rm tengine.zip \
#        && cd /usr/src/tengine-$TENGINE_VERSION/modules \
#        && curl -L "https://github.com/openresty/set-misc-nginx-module/archive/master.zip" -o set-misc-nginx-module.zip \
#        && unzip set-misc-nginx-module.zip \
#        && rm set-misc-nginx-module.zip \
#        && curl -L "https://github.com/simpl/ngx_devel_kit/archive/master.zip" -o ngx_devel_kit.zip \
#        && unzip ngx_devel_kit.zip \
#        && rm ngx_devel_kit.zip \
#        && curl -L "https://github.com/leev/ngx_http_geoip2_module/archive/master.zip" -o ngx_http_geoip2_module.zip \
#        && unzip ngx_http_geoip2_module.zip \
#        && rm ngx_http_geoip2_module.zip \
#        && curl -L "https://github.com/openresty/headers-more-nginx-module/archive/master.zip" -o headers-more-nginx-module.zip \
#        && unzip headers-more-nginx-module.zip \
#        && rm headers-more-nginx-module.zip \
#        && curl -L "https://github.com/nbs-system/naxsi/archive/master.zip" -o naxsi.zip \
#        && unzip naxsi.zip \
#        && rm naxsi.zip \
#        && git clone https://github.com/google/ngx_brotli.git \
#        && cd /usr/src/tengine-$TENGINE_VERSION/modules/ngx_brotli \
#        && git submodule update --init --recursive \
#        && cd /usr/src/ \
#        && curl -L "http://ftp.pcre.org/pub/pcre/pcre-8.44.zip" -o pcre.zip \
#        && unzip pcre.zip \
#        && rm pcre.zip \
#        && cd /usr/src/pcre-8.44 \
#        && ./configure --enable-jit \
#        && make \
#        && make install \
#        && ls -l /usr/src/tengine-$TENGINE_VERSION/modules \
#        && cd /usr/src/tengine-$TENGINE_VERSION \
#        && ./configure $CONFIG \
#        && make \
#        && make install \
#        && rm -rf /usr/src/tengine-$NGINX_VERSION 

#OFFLINE
RUN mkdir -p /usr/src/
COPY ./tengine/ /usr/src/
RUN ls -l /usr/src/

RUN cd /usr/src/pcre-8.44 && ./configure --enable-jit && make && make install

RUN cd /usr/src/tengine-master && ./configure $CONFIG && make && make install && rm -rf /usr/src/tengine-master 
        
#EXPOSE 80 443

STOPSIGNAL SIGTERM

#RUN ln -sf /dev/stdout /var/log/nginx/access.log \
#    && ln -sf /dev/stderr /var/log/nginx/error.log


RUN echo "America/Sao_Paulo" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
RUN apt-get install ntp -y --fix-missing
RUN echo 'server 0.centos.pool.ntp.org' >> /etc/ntp.conf
RUN echo 'server 1.centos.pool.ntp.org' >> /etc/ntp.conf
RUN echo 'server 2.centos.pool.ntp.org' >> /etc/ntp.conf

RUN apt-get remove -y gcc flex make bison build-essential pkg-config
RUN apt-get remove -y g++ libtool automake autoconf software-properties-common
RUN apt-get remove -y git automake autotools-dev
RUN apt-get remove --purge --auto-remove -y && apt-get clean && rm -rf /var/lib/apt/lists/*
        
RUN rm -fr /tmp/*

RUN mkdir -p /var/cache/nginx/
RUN mkdir -p /etc/nginx/extras
RUN nginx -t

CMD nginx -g 'daemon off;'
