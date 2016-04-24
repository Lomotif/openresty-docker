FROM alpine:3.3

# Add our www-data group and user
RUN addgroup -S www-data && adduser -S -G www-data www-data

ENV OPENRESTY_VERSION 1.9.7.3
# RUN apt-get update \
# 	&& apt-get install -y libreadline-dev libncurses5-dev libpcre3-dev libssl-dev libpq-dev perl make build-essential \
# 	&& apt-get clean \
# 	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN echo "http://dl-1.alpinelinux.org/alpine/v3.3/main" >> /etc/apk/repositories; \
    echo "http://dl-2.alpinelinux.org/alpine/v3.3/main" >> /etc/apk/repositories; \
    echo "http://dl-3.alpinelinux.org/alpine/v3.3/main" >> /etc/apk/repositories; \
    echo "http://dl-4.alpinelinux.org/alpine/v3.3/main" >> /etc/apk/repositories; \
    echo "http://dl-5.alpinelinux.org/alpine/v3.3/main" >> /etc/apk/repositories; \
    apk add --update --no-cache readline-dev ncurses-dev pcre-dev openssl openssl-dev postgresql-dev gd-dev zlib-dev perl make build-base
	
RUN mkdir /usr/local/src \
	&& cd /usr/local/src \
	&& wget https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz \
	&& tar xzvf openresty-${OPENRESTY_VERSION}.tar.gz \
	&& cd openresty-${OPENRESTY_VERSION} \
	&& ./configure \
		--with-pcre-jit \
		--with-ipv6 \
		--with-http_postgres_module \
		--without-lua_resty_mysql \
		--with-http_image_filter_module \
		--sbin-path=/usr/sbin/nginx \
		--conf-path=/etc/nginx/nginx.conf \
		--http-proxy-temp-path=/var/cache/nginx \
		--http-client-body-temp-path=/var/cache/nginx \
		--http-fastcgi-temp-path=/var/cache/nginx \
		--http-scgi-temp-path=/var/cache/nginx \
		--http-uwsgi-temp-path=/var/cache/nginx \
		--error-log-path=/var/log/nginx/error.log \
		--pid-path=/var/run/nginx.pid \
		--http-log-path=/var/log/nginx/access.log \
		--user=www-data \
		--group=www-data \
	&& mkdir -p /etc/nginx \
	&& mkdir -p /etc/nginx/sites-available \
	&& mkdir -p /etc/nginx/sites-enabled \
	&& mkdir -p /etc/nginx/conf.d \
	&& mkdir -p /var/log/nginx/ \
	&& mkdir -p /var/cache/nginx \
	&& make \
	&& make install \
	&& cd \
	&& rm -rf /usr/local/src/openresty*

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/detailed.logformat /etc/nginx/conf.d/detailed.logformat
COPY nginx/reload /reload

EXPOSE 80 443
CMD ["-p", "/etc/nginx", "-c", "/etc/nginx/nginx.conf"]
ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]


