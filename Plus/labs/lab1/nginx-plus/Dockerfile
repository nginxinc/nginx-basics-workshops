# Use the private image as the base
FROM private-registry.nginx.com/nginx-plus/agent:debian

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

# If you need to install additional tools/packages
RUN apt-get update && apt-get install -y curl vim
