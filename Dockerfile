FROM alpine:3.6

# Add our www-data group and user
RUN addgroup -S www-data && adduser -S -G www-data www-data

ENV OPENRESTY_VERSION 1.11.2.4

# FIXME: We'd ideally want to install libpq-dev for postgres library dev headers, but it looks like
#	 Alpine isn't quite up to speed on that as yet. Once they publish that package, we should switch
#	 to that from postgresql-dev below, which is the full postgres library, and hence far larger.
# 	 Ref: http://bugs.alpinelinux.org/issues/3642
RUN apk add --update --no-cache --virtual .build-deps build-base gd-dev pcre-dev make perl-dev readline-dev zlib-dev openssl-dev && \
    apk add --update --no-cache nginx openssl gd libgcc zlib pcre && \
    mkdir /usr/local/src \
	&& cd /usr/local/src \
	&& wget https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz \
	&& tar xzvf openresty-${OPENRESTY_VERSION}.tar.gz \
	&& cd openresty-${OPENRESTY_VERSION} \
	&& ./configure \
		--with-pcre-jit \
		--with-ipv6 \
		--with-http_v2_module \
		--with-http_stub_status_module \
		--without-lua_resty_mysql \
		--without-http_redis2_module \
		--without-http_redis_module \
		--without-mail_pop3_module \
		--without-mail_smtp_module \
		--with-http_image_filter_module \
		--sbin-path=/usr/sbin/nginx \
		--conf-path=/etc/nginx/nginx.conf \
		--http-proxy-temp-path=/var/lib/nginx/proxy \
		--http-client-body-temp-path=/var/lib/nginx/body \
		--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
		--http-scgi-temp-path=/var/lib/nginx/scgi \
		--http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
		--error-log-path=/var/log/nginx/error.log \
		--pid-path=/var/run/nginx.pid \
		--http-log-path=/var/log/nginx/access.log \
		--user=www-data \
		--group=www-data \
	&& make \
	&& make install \
	&& cd \
	&& rm -rf /usr/local/src/openresty* \
	&& apk del .build-deps

RUN mkdir -p /etc/nginx \
	&& mkdir -p /etc/nginx/sites-available \
	&& mkdir -p /etc/nginx/sites-enabled \
	&& mkdir -p /etc/nginx/conf.d \
	&& mkdir -p /etc/nginx/lua \
	&& mkdir -p /etc/nginx/lua/modules \
	&& mkdir -p /etc/nginx/lua/init \
	&& mkdir -p /var/log/nginx/ \
	&& mkdir -p /var/lib/nginx \
	# forward request and error logs to docker log collector
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx.init /nginx.init
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/lua/modules /etc/nginx/lua/modules
COPY nginx/lua/init /etc/nginx/lua/init
COPY nginx/detailed.logformat /etc/nginx/conf.d/detailed.logformat
COPY nginx/reload /reload

EXPOSE 80 443
CMD ["-p", "/etc/nginx", "-c", "/etc/nginx/nginx.conf"]
ENTRYPOINT ["/nginx.init"]


