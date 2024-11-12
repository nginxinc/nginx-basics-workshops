# For Ubuntu 20.04:
FROM ubuntu:focal

## Install Nginx Plus
# Download certificate and key from the MyF5 customer portal (https://account.f5.com/myf5)
# and copy to the build context and set correct permissions
RUN mkdir -p /etc/ssl/nginx
COPY etc/ssl/nginx/nginx-repo.* /etc/ssl/nginx/
RUN chmod 644 /etc/ssl/nginx/* 

# Install prerequisite packages:
RUN apt-get update && apt-get install -y apt-transport-https lsb-release ca-certificates curl wget gnupg2 net-tools vim tree openssl jq

# Download and add the NGINX signing key:
RUN wget https://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key 

# Add NGINX Plus repository:
RUN printf "deb https://pkgs.nginx.com/plus/ubuntu `lsb_release -cs` nginx-plus\n" | tee /etc/apt/sources.list.d/nginx-plus.list

# Download the apt configuration to `/etc/apt/apt.conf.d`:
RUN wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx

# <TODO:  modify apt-get install command to pull R32 ( no R33 allowed ):
# HELP:  https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-docker/#creating-custom-nginx-plus-docker-image
# Update the repository and install version R32P1 of NGINX Plus:
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y nginx-plus=32-2*

# Remove nginx repository key/cert from docker
RUN rm -rf /etc/ssl/nginx \
# Remove default nginx config
# && rm /etc/nginx/conf.d/default.conf \
# Required for this demo: Create State file folder and set permissions
&& mkdir -p /var/lib/nginx/state \
&& chown -R nginx /var/lib/nginx/state \
# COPY var/lib/nginx/state/upstreams.state /var/lib/nginx/state/upstreams.state
&& touch /var/lib/nginx/state/upstreams.state

# Copy certificate files and dhparams
COPY etc/ssl /etc/ssl

# COPY /etc/nginx (Nginx configuration) directory
COPY etc/nginx /etc/nginx
RUN chown -R nginx:nginx /etc/nginx \
# # Forward request logs to Docker log collector:
# && ln -sf /dev/stdout /var/log/nginx/access.log \
# && ln -sf /dev/stderr /var/log/nginx/error.log \
 # Remove the cert/keys from the image
&& rm /etc/ssl/nginx/nginx-repo.crt /etc/ssl/nginx/nginx-repo.key

# COPY /usr/share/nginx/html (Nginx files) directory
COPY usr/share/nginx/html /usr/share/nginx/html
RUN chown -R nginx:nginx /usr/share/nginx/html

# EXPOSE ports, HTTP 80, HTTP 8080, HTTPS 443, Nginx API / status page 9000, Prometheus Exporter page 9113
EXPOSE 80 443 8080 9000 9113
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]
