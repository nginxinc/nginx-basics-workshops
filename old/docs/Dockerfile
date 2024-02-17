FROM nginx:mainline-alpine
RUN rm /etc/nginx/conf.d/*

# COPY Markdown files
COPY labs /usr/share/nginx/html/labs
COPY misc/strapdown /usr/share/nginx/html/strapdown

RUN chown -R nginx:nginx /usr/share/nginx/html 
ADD misc/lab_guide.conf /etc/nginx/conf.d/
RUN chown -R nginx:nginx /etc/nginx \
 # Forward request logs to docker log collector
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log \
 # Raise the limits to successfully run benchmarks
 && ulimit -c -m -s -t unlimited