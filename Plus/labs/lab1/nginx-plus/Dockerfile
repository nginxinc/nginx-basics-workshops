# Use the private image as the base
FROM private-registry.nginx.com/nginx-plus/modules:r33-headers_more-debian as temp_base

FROM private-registry.nginx.com/nginx-plus/rootless-agent:r33-debian-bookworm

COPY --from=temp_base / /

# Set some default environment variables (can be overridden at runtime)
ENV NGINX_LICENSE_JWT=""
ENV NGINX_AGENT_SERVER_GRPCPORT=443
ENV NGINX_AGENT_SERVER_HOST=agent.connect.nginx.com
ENV NGINX_AGENT_SERVER_TOKEN=""
ENV NGINX_AGENT_TLS_ENABLE=true

# Copy NGINX Configs as it is not being mounted
COPY --chown=nginx:nginx ./etc/nginx/conf.d /etc/nginx/conf.d
COPY --chown=nginx:nginx ./etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY --chown=nginx:nginx ./etc/nginx/includes /etc/nginx/includes
COPY --chown=nginx:nginx ./etc/ssl/nginx/nginx-repo.* /etc/ssl/nginx/