FROM nginx:mainline-alpine
RUN rm /etc/nginx/conf.d/*

# COPY usr/share/nginx/html (Web content) directory
COPY usr/share/nginx/html /usr/share/nginx/html
# COPY /etc/nginx (Nginx configuration) directory
COPY etc/nginx /etc/nginx
RUN chown -R nginx:nginx /etc/nginx \
 # Forward request logs to docker log collector
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log \
 # Raise the limits to successfully run benchmarks
 && ulimit -c -m -s -t unlimited