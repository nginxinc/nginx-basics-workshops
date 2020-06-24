FROM ubuntu:18.04

LABEL maintainer="armand@nginx.com"

## Install Nginx Plus
# Download certificate and key from the customer portal https://cs.nginx.com
# and copy to the build context and set correct permissions
RUN mkdir -p /etc/ssl/nginx
COPY etc/ssl/nginx/nginx-repo.crt /etc/ssl/nginx/nginx-repo.crt
COPY etc/ssl/nginx/nginx-repo.key /etc/ssl/nginx/nginx-repo.key
RUN chmod 644 /etc/ssl/nginx/* \
    # Install prerequisite packages and vim for editing:
    && apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends apt-transport-https lsb-release ca-certificates wget dnsutils gnupg vim-tiny \
    # Install NGINX Plus from repo (https://cs.nginx.com/repo_setup)
    && wget http://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key \
    && printf "deb https://plus-pkgs.nginx.com/ubuntu `lsb_release -cs` nginx-plus\n" | tee /etc/apt/sources.list.d/nginx-plus.list \
    && wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90nginx \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus \
    ## Optional: Install NGINX Plus Dynamic Modules (3rd-party) from repo
    ## See https://www.nginx.com/products/nginx/modules
    ## For debug binaries, install module ending with "-dbg"
    ## brotli compression dynamic modules
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-brotli \
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-brotli-dbg \
    ## cookie flag dynamic module
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-cookie-flag \
    ## encrypted session dynamic module
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-encrypted-session \
    ## GeoIP dynamic modules
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-geoip \
    ## GeoIP2 dynamic modules
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-geoip2 \
    ## headers-more dynamic module
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-headers-more \
    ## image filter dynamic module
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-image-filter \
    ## Lua dynamic module
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-lua \
    ## ModSecurity dynamic module
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-modsecurity \
    ## NDK dynamic module
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-ndk \
    ## njs dynamic modules
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-njs \
    ## OpenTracing dynamic module
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-opentracing \
    ## Passenger dynamic module
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-passenger \
    ## Perl dynamic module
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-perl \
    ## Prometheus exporter NJS module
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-prometheus \
    ## RTMP dynamic module
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-rtmp \
    ## set-misc dynamic module
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-set-misc \
    ## substitution dynamic module
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-subs-filter \
    ## xslt dynamic module
    # && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install --no-install-recommends nginx-plus-module-xslt \
    # Cleanup
    && rm -rf /var/lib/apt/lists/* \
    # Remove default nginx config
    && rm /etc/nginx/conf.d/default.conf \
    # Required for this demo: Create cache folder and set permissions for proxy caching
    && mkdir -p /var/cache/nginx \
    && chown -R nginx /var/cache/nginx \
    # Required for this demo: Create State file folder and set permissions
    && mkdir -p /var/lib/nginx/state \
    && chown -R nginx /var/lib/nginx/state \
    # COPY var/lib/nginx/state/servers.conf /var/lib/nginx/state/servers.conf
    && touch /var/lib/nginx/state/servers.conf \
    # Required for this demo: COPY over any of your SSL certs for HTTPS servers
    && mkdir -p /etc/ssl/dhparam/2048 \
    && mkdir -p /etc/ssl/dhparam/4096

# Copy certificate files and dhparams
COPY etc/ssl /etc/ssl

# COPY /etc/nginx (Nginx configuration) directory
COPY etc/nginx /etc/nginx
RUN chown -R nginx:nginx /etc/nginx \
 # Forward request logs to docker log collector
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log \
 # Raise the limits to successfully run benchmarks
 && ulimit -c -m -s -t unlimited \
 # Remove the cert/keys from the image
 && rm /etc/ssl/nginx/nginx-repo.crt /etc/ssl/nginx/nginx-repo.key

# EXPOSE ports, HTTP 80, HTTPS 443 and, Nginx status page 8080
EXPOSE 80 443 8080
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]