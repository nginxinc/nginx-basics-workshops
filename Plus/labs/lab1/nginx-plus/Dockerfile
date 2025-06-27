# Use the private image as the base
FROM private-registry.nginx.com/nginx-plus/agent:r33-debian-bookworm


# Set some default environment variables (can be overridden at runtime)
ENV NGINX_LICENSE_JWT=""
ENV NGINX_AGENT_SERVER_GRPCPORT=443
ENV NGINX_AGENT_SERVER_HOST=agent.connect.nginx.com
ENV NGINX_AGENT_SERVER_TOKEN=""
ENV NGINX_AGENT_TLS_ENABLE=true

# Copy NGINX Configs as it is not being mounted
COPY ./etc/nginx/conf.d /etc/nginx/conf.d
COPY ./etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./etc/nginx/includes /etc/nginx/includes
COPY ./etc/ssl/nginx/nginx-repo.* /etc/ssl/nginx/
COPY ./etc/nginx/license.jwt /etc/nginx/license.jwt

# Section to  install additional tools/packages
# RUN apt-get update && apt-get install -y curl vim
RUN apt-get update && apt-get install -y curl vim apt-transport-https lsb-release ca-certificates wget gnupg2 debian-archive-keyring

# Section to install additional NGINX Modules or packages 
RUN wget -qO - https://cs.nginx.com/static/keys/nginx_signing.key \
    | gpg --dearmor \
    | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

RUN printf "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
https://pkgs.nginx.com/plus/debian `lsb_release -cs` nginx-plus\n" \
| tee /etc/apt/sources.list.d/nginx-plus.list

RUN wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx

RUN apt-get update && apt-get install -y nginx-plus-module-headers-more