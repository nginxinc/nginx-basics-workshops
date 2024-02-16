FROM nginx:mainline-alpine
RUN apk add --no-cache curl ca-certificates bash bash-completion jq wget vim

# Copy certificate files and dhparams
COPY etc/ssl /etc/ssl

# Copy nginx config files
COPY /etc/nginx /etc/nginx
RUN chown -R nginx:nginx /etc/nginx

# EXPOSE ports, HTTP 80, HTTPS 443, Nginx stub_status page 9000
EXPOSE 80 443 9000
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]
