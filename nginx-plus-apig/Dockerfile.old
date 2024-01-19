FROM alpine:3.11

LABEL maintainer="armand@nginx.com"

ENV VEGETA_VERSION=12.3.0
ENV SIEGE_VERSION=3.1.4

## Install Nginx Plus
# Download certificate and key from the customer portal https://cs.nginx.com
# and copy to the build context and set correct permissions
COPY etc/ssl/nginx/nginx-repo.crt /etc/apk/cert.pem
COPY etc/ssl/nginx/nginx-repo.key /etc/apk/cert.key
RUN chmod 644 /etc/apk/cert* \
 # Prepare repo config and install NGINX Plus (https://cs.nginx.com/repo_setup)
 && wget -O /etc/apk/keys/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
 && printf "https://plus-pkgs.nginx.com/alpine/v`egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release`/main\n" | tee -a /etc/apk/repositories \
 && apk add nginx-plus \
 ## Optional: Install NGINX Plus Dynamic Modules (3rd-party) from repo
 ## See https://www.nginx.com/products/nginx/modules
 ## For debug binaries, install module ending with "-dbg"
 ## brotli compression dynamic modules
 # && apk add nginx-plus-module-brotli \
 # && apk add nginx-plus-module-brotli-dbg \
 ## cookie flag dynamic module
 # && apk add nginx-plus-module-cookie-flag \
 ## encrypted session dynamic module
 # && apk add nginx-plus-module-encrypted-session \
 ## GeoIP dynamic modules
 # && apk add nginx-plus-module-geoip \
 ## GeoIP2 dynamic modules
 # && apk add nginx-plus-module-geoip2 \
 ## headers-more dynamic module
 # && apk add nginx-plus-module-headers-more \
 ## image filter dynamic module
 # && apk add nginx-plus-module-image-filter \
 ## Lua dynamic module
 # && apk add nginx-plus-module-lua \
 ## ModSecurity dynamic module
 # && apk add nginx-plus-module-modsecurity \
 ## NDK dynamic module
 # && apk add nginx-plus-module-ndk \
 # REQUIRED FOR THIS DEMO: njs dynamic modules
 && apk add nginx-plus-module-njs \
 ## OpenTracing dynamic module
 # && apk add nginx-plus-module-opentracing \
 ## Passenger dynamic module
 # && apk add nginx-plus-module-passenger \
 ## Perl dynamic module
 # && apk add nginx-plus-module-perl \
 ## Prometheus exporter NJS module
 # && apk add nginx-plus-module-prometheus \
 ## RTMP dynamic module
 # && apk add nginx-plus-module-rtmp \
 ## set-misc dynamic module
 # && apk add nginx-plus-module-set-misc \
 ## substitution dynamic module
 # && apk add nginx-plus-module-subs-filter \
 ## xslt dynamic module
 # && apk add nginx-plus-module-xslt \
 ## REQUIRED TOOLS FOR THIS DEMO:
 # curl and jq
 && apk add curl jq\
 # Clear apk cache
 && rm -rf /var/cache/apk/* \
 # Remove default nginx config
 && rm /etc/nginx/conf.d/default.conf \
 # Optional: Create cache folder and set permissions for proxy caching
 && mkdir -p /var/cache/nginx \
 && chown -R nginx /var/cache/nginx \
 # Optional: Create State file folder and set permissions
 && mkdir -p /var/lib/nginx/state \
 && chown -R nginx /var/lib/nginx/state \
 # Vegeta load generator
 && set -ex \
 && apk add --no-cache ca-certificates \
 && apk add --no-cache --virtual .build-deps openssl \
 && wget -q "https://github.com/tsenart/vegeta/releases/download/cli/v$VEGETA_VERSION/vegeta-$VEGETA_VERSION-linux-amd64.tar.gz" -O /tmp/vegeta.tar.gz \
 && cd bin \
 && tar xzf /tmp/vegeta.tar.gz \
 && rm /tmp/vegeta.tar.gz \
 && apk del .build-deps \
 # Siege load generator
 && apk add g++ make \
 && curl http://download.joedog.org/siege/siege-$SIEGE_VERSION.tar.gz > siege-$SIEGE_VERSION.tar.gz \
 && tar -xf siege-${SIEGE_VERSION}.tar.gz \
 && cd siege-${SIEGE_VERSION} \
 && ./configure \
 && make install \
 # Clear apk cache
 && rm -rf /var/cache/apk/*

# Required for this demo: COPY over any of your SSL certs for HTTPS servers
COPY etc/ssl/certs/api.example.com.crt /etc/ssl/certs/api.example.com.crt
COPY etc/ssl/private/api.example.com.key /etc/ssl/private/api.example.com.key

# COPY /etc/nginx (Nginx configuration) directory
COPY etc/nginx /etc/nginx
RUN chown -R nginx:nginx /etc/nginx \
 # Forward request logs to docker log collector
 # && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stdout /var/log/nginx/api_access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log \
 # **Remove the Nginx Plus cert/keys from the image**
 && rm /etc/apk/cert.pem /etc/apk/cert.key

# EXPOSE ports, HTTP 80, HTTPS 443 and, Nginx status page 8080
EXPOSE 80 443 8080
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]