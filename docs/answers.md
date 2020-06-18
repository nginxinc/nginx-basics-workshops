# Recommended Answers

There are hundreds of ways to acheive the same objective with NGINX.conf.

Here are recommended answers for the SE Challenge questions

## Minimum requirements

### HTTP to HTTPS redirect

**Goal:** HTTP to HTTPS redirect service for `www2.example.com`. Candidate can demostrate this working in a web browser or using `curl`

1. A typical HTTP/S redirect server block

```nginx
# www2.example.com HTTP Redirect to HTTPS
server {
    listen 80;
    server_name www2.example.com;
    return 301 https://$host$request_uri;
}
```

2. We can use `curl` to validate the HTTP to HTTPS redirect for `www2.example.com`. The following `curl` flags are required:
 * `-L` will follow redirects
 * `-k` allow insecure

```bash
curl --header "Host: www2.example.com" http://127.0.0.1/ -k -L -I

HTTP/1.1 301 Moved Permanently
Server: nginx/1.17.9
Date: Tue, 19 May 2020 13:35:52 GMT
Content-Type: text/html
Content-Length: 169
Connection: keep-alive
Location: https://www2.example.com/

HTTP/1.1 200 OK
Server: nginx/1.17.9
Date: Tue, 19 May 2020 13:35:52 GMT
Content-Type: text/html
Connection: keep-alive
Expires: Tue, 19 May 2020 13:35:51 GMT
Cache-Control: no-cache
```

### HTTPS service for `www2.example.com` 

**Goal:** Configure a HTTPS service for `www2.example.com`. There are self-signed certificates provided that can be used here. 
Candidate may configure the minimum or granular configurations for added [performance or security best practices]([SSL Configuration Generator](https://ssl-config.mozilla.org). 

NGINX Plus should provide SSL termination and proxy upstream servers over HTTP (i.e. Client -> HTTPS -> NGINX -> HTTP -> webserver)

```nginx
# www2.example.com HTTP Redirect to HTTPS
server {
    listen 80;
    server_name www2.example.com;
    return 301 https://$host$request_uri;
}
# ww2.example.com HTTPS
server {
    listen 443 ssl default_server;
    status_zone www2.example.com_https;
    server_name www2.example.com;

    # Minimum SSL Configuration
    ssl_certificate /etc/ssl/example.com.crt;
    ssl_certificate_key /etc/ssl/example.com.key;

    # Include best-practice SSL Configurations are bonus points:
    # include includes/ssl/ssl_intermediate.conf;

    location / {
        
        # Including best-practice headers are bonus points
        include includes/proxy_headers/proxy_headers.conf;
        include includes/proxy_headers/keep_alive.conf;
        
        # HTTP proxy to the upstream
        proxy_pass http://nginx_hello;
    }

}
```
### Enable keepalive connections to upstream servers 

**Goal:** Enable keepalive connections o upstream servers for performance; greatly reduce the number of new TCP connections, as Nginx can now reuse its existing connections (keepalive) per upstream.

**Notes:**
 * An Nginx configuration however, by default, only talks HTTP/1 to the upstream. Keepalive connections are only supported as of HTTP/1.1, an upgrade to the HTTP protocol. 
 * The connections parameter sets the maximum number of idle keepalive connections to upstream servers that are preserved in the cache of each worker process. When this number is exceeded, the least recently used connections are closed.
 * If your upstream server supports keepalive in its config, Nginx will now reuse existing TCP connections without creating new ones. This can greatly reduce the number of `TIME_WAIT` TCP connections on a busy SSL server.

#### How HTTP Works Without Keep-Alive
A client has to create a new connection to interact and receive a file from a server
The client requests an HTML file using a new connection and this connection terminates after receiving the file
The browser interprets the HTML file and checks whether any other files are required to display the complete web page
After a thorough analysis, it creates a new connection to request each of those files


#### Benefits of Keep-Alive
All modern browsers use persistent connections as long as the server is willing to cooperate. Check your application and proxy server configurations to make sure that they support Keep-Alive. You need to pay close attention to the default behavior of HTTP libraries as well.

You may also use HTTP/1.1, where Keep-Alive is implemented differently and the connections are kept open by default. Unlike HTTP/1.0 keep-alive connections, HTTP/1.1 connections are always active. HTTP/1.1 assumes all connections are persistent unless the response contains a "Connection: close" header. But not sending "Connection: close" does not mean that the server maintains the connection forever and it's still possible for the connection to be dropped.

 * Reduced CPU Usage: Creating new TCP connections can take a lot of resources such as CPU and memory usage. Keeping connections alive longer can reduce this usage.
 * Web page speed: The ability to serve multiple files using the same connection can reduce latency and allow web pages to load faster.
 * HTTPS: HTTPS connections (content over Secure Socket Layer) are very resource intensive. So it is highly recommended to enable Keep-Alive for HTTPS connections and maybe spice it a bit with HTTP/2.


1. To enable [keepalive connections](https://www.nginx.com/blog/http-keepalives-and-web-performance/) to upstream servers you must also include the following directives in the configuration:


```nginx
# Directives can be placed in http, server or location
proxy_http_version 1.1;
proxy_set_header Connection "";


upstream nginx_hello {

    zone nginx_hello 64k;
    server nginx1:80;
    server nginx2:80;

    keepalive 32; # <-- added into upstream
}
```

## Extra Credits  

### Enable a Active HTTP Health Check

**Goal:** Periodically check the health of upstream servers by sending a custom health‑check requests to each server and verifying the correct response. E.g. check for a `HTTP 200` response and `content type: text/html`. The candidate should be able to describe the benefits Active Health Checks


1. A simple health check can be created like so

```nginx
# Simple health check expecting http 200 and correct Content-Type
match status_ok {
    status 200;
    header Content-Type = text/html; # For the nginx-hello html
    #header Content-Type = text/plain; # For the nginx-hello plain text
}
```

2. we should be able to see checks increment under Health monitors in the NGINX Plus dashboard

### Enable a non-default HTTP load balancing algorithm

**Goal:** Enable a HTTP load balancing algorithm **other than the default**, round-robin. Any of the available load balancing algorithm below can be used. The candidate should be able to describe how the algorithm works and its benefits

1. Any of the load balancing algorithm below can be used
   
```nginx
upstream {

    # Including keep alive connections are bonus points
    keepalive 32;

    zone nginx_hello 64k;
    server nginx1:80;
    server nginx2:80;
#
# - Round Robin (the default)
#   Distributes requests in order across the list of upstream servers.
#
# - Least Connections
#   Sends requests to the server with the lowest number of
#   active connections.
#   e.g.
#   least_conn;
#
# - Least Time
#   Exclusive to NGINX Plus. Sends requests to the server selected by a
#   formula that combines the fastest response time and fewest active
#   connections: `least_time header | last_byte [inflight];`
#   e.g.
#   least_time last_byte;
#
#  - Hash
#    Distributes requests based on a key you define, such as the client IP
#    address or the request URL. NGINX Plus can optionally apply a consistent
#    hash to minimize redistribution of loads if the set of upstream servers
#    changes: `hash key [consistent];`
#    e.g.
#    hash $request_uri consistent;
#
#  - IP Hash (HTTP only)
#    Distributes requests based on the first three octets of
#    the client IP address.
#    e.g.
#    ip_hash;
#
#  - Random with Two Choices
#    Picks two servers at random and sends the request to the one that is
#    selected by then applying the Least Connections algorithm (or for NGINX Plus
#    the Least Time algorithm, if so configured): `random [two [method]]`
#    e.g.
#    random two; # Round Robin
#    random two least_conn; # Least connections
#    random two least_time=last_byte; # Least time: use header or last_byte

}
```

### Provide the command to add and remove server from the NGINX upstream

**Goal:** Demonstrate the capability to use a command line tool such as [`curl`](https://ec.haxx.se/http-cheatsheet.html) or similar, [dynamically configure the Upstreams](https://docs.nginx.com/nginx/admin-guide/load-balancer/dynamic-configuration-api/), `dynamic`,  with the NGINX Plus API: e.g. 
 * Add and remove server the upstream
 * Drain a upstream server
 * Mark a upstream server up or down
 * Change

Bonus points for using tools like [jq](https://stedolan.github.io/jq/) to parse and format the returned JSON data

The candidate should be able to describe the benefits of a on-the-fly reconfiguration API

```bash
# Managing Upstream Servers with the API
#-----------------------------------------

# List out servers in our upstream, `dynamic`
curl -s http://localhost:8080/api/6/http/upstreams/dynamic/servers | jq
[]

# Add a new server to the appservers upstream group, send the following curl command:
# We could add servers: nginx1:80 and nginx2:80

# Add nginx1:
curl -s -X \
POST http://localhost:8080/api/6/http/upstreams/dynamic/servers \
-H 'Content-Type: text/json; charset=utf-8' \
-d @- <<'EOF'

{
  "server": "nginx1:80",
  "max_conns": 0,
  "max_fails": 1,
  "fail_timeout": "10s",
  "slow_start": "0s",
  "route": "",
  "backup": false,
  "down": false
}
EOF

{"id":0,"server":"nginx1:80","weight":1,"max_conns":0,"max_fails":1,"fail_timeout":"10s","slow_start":"0s","route":"","backup":false,"down":false}

# Add nginx2:
curl -s -X \
POST http://localhost:8080/api/6/http/upstreams/dynamic/servers \
-H 'Content-Type: text/json; charset=utf-8' \
-d @- <<'EOF'

{
  "server": "nginx2:80",
  "max_conns": 0,
  "max_fails": 1,
  "fail_timeout": "10s",
  "slow_start": "0s",
  "route": "",
  "backup": false,
  "down": false
}
EOF

{"id":2,"server":"nginx2:80","weight":1,"max_conns":0,"max_fails":1,"fail_timeout":"10s","slow_start":"0s","route":"","backup":false,"down":false}

# Once again, list out servers in our upstream, `dynamic`
curl -s http://localhost:8080/api/6/http/upstreams/dynamic/servers | jq

# To remove a server (with ID 0) from the upstream group:
curl -X DELETE -s http://localhost:8080/api/6/http/upstreams/dynamic/servers/0 | jq

# To set the down parameter for the first server (with ID 1) in the group:
curl -X PATCH -d '{ "down": true }' -s 'http://localhost:8080/api/6/http/upstreams/dynamic/servers/1' | jq

# Once again, list out servers in our upstream, `dynamic`
curl -s http://localhost:8080/api/6/http/upstreams/dynamic/servers | jq

# Inspect the `state` file on the NGINX server:
cat /var/lib/nginx/state/servers.conf # from the container
docker exec -it nginx-se-challenge_nginx-plus_1 cat /var/lib/nginx/state/servers.conf # from docker host

# If we reload the config we will see NGINX load our upstream, `dynamic` from the `state` file:
# Note: The ID's are incremented from `0` on reload
# Reload nginx
nginx -s reload # from the container
docker exec -it nginx-se-challenge_nginx-plus_1 nginx -s reload # from docker host

# list out servers in our upstream, `dynamic`
curl -s http://localhost:8080/api/6/http/upstreams/dynamic/servers | jq
```

### Create a `HTTP 301` URL redirect

**Goal:** Create a `HTTP 301` URL redirect for `/old-url` to `/new-url` and demonstrate the redirection. This can be demonstrated in a web browser or using a command line tool such as `curl`. The candidate may use `return` or `rewrite` but the `return` directive should be used here


1. The `return` directive should be used here, it is the most simple and fastest (no regex processing) option and should be used where possible

```nginx
server {
    # Enabling rewrite logging is bonus points
    # Enables logging of ngx_http_rewrite_module module directives 
    # processing results into the error_log at the notice level
    rewrite_log on;
    
    # answer:
    location = /old-url { return 301 new-url; } # 301 MOVED PERMANENTLY
}
```

2. Example curl command

```bash
curl http://localhost/old-url -L -I

HTTP/1.1 301 Moved Permanently
Server: nginx/1.17.9
Date: Tue, 19 May 2020 12:35:47 GMT
Content-Type: text/html
Content-Length: 169
Connection: keep-alive
Location: new-url

HTTP/1.1 200 OK
Server: nginx/1.17.9
Date: Tue, 19 May 2020 12:35:47 GMT
Content-Type: text/html
Connection: keep-alive
Expires: Tue, 19 May 2020 12:35:46 GMT
Cache-Control: no-cache
```

### Enable content caching for image files only

**Goal:** Enable Proxy caching for content ending with common image file extensions. Use the Cache folder provisioned on `/var/cache/nginx`, i.e. set `proxy_cache_path` to `/var/cache/nginx`. Although not required, the candidate may enable granual cache settings and even setup cache purge. The Candidate should be able to explain all the directives enabled here

1. Below is an example of a proxy cache configuration with minimum requirements and extra configurations

```nginx
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=mycache:10m;

server {
    #...

    # Match common Image files
    location ~* \.(?:jpg|jpeg|gif|png|ico|cur|gz|svg|svgz|mp4|ogg|ogv|webp|webm|htc)$ {

        ## Proxy cache settings
        # Required
        proxy_cache mycache;

        # Extra
        proxy_cache_valid 200 1h;
        proxy_cache_valid 301 302 10m;
        proxy_cache_valid 404 1m;
        proxy_cache_valid any 10s;
        # cache purge API (not required but would be bonus points)
        # proxy_cache_purge $purge_method;
        # cache status
        add_header X-Cache-Status $upstream_cache_status;
        # override cache headers
        proxy_ignore_headers X-Accel-Expires Expires Cache-Control Set-Cookie;
        expires 365d;
        add_header Cache-Control "public";

        proxy_pass http://nginx_hello;
    }

}
```

2. We can validate the cache is working using `curl`

```bash
curl http://localhost/smile.png -I

HTTP/1.1 200 OK
Server: nginx/1.17.9
Date: Tue, 19 May 2020 13:06:01 GMT
Content-Type: image/png
Content-Length: 107753
Connection: keep-alive
Last-Modified: Tue, 19 May 2020 12:52:04 GMT
ETag: "5ec3d674-1a4e9"
Expires: Wed, 19 May 2021 13:06:01 GMT # <-- Expires one year from today
Cache-Control: max-age=31536000
X-Cache-Status: HIT  # <-- IF X-Cache-Status enabled
Cache-Control: public   # <-- We set this also
Accept-Ranges: bytes

```

### Provide the command to execute a the NGINX command on the a running container 

**Goal:** Demonstrate Docker compentency by running a command on a running container. For example,  
 * `nginx -t` to check nginx config file, and 
 * `nginx -s reload` to Reload the configuration file

```bash
docker exec [options] CONTAINER COMMAND
  -d, --detach        # run in background
  -i, --interactive   # stdin
  -t, --tty           # interactive
```

```bash
# e.g. Execute a echo command on a running container
docker exec -it <container_id_or_name> echo "Hello from container!"

# Execute a the NGINX command `nginx -t` on the a running NGINX Plus container 
docker exec -it se_challenge_nginx-plus_1 nginx -t

# Execute a the NGINX command `nginx -s reload` on the a running NGINX Plus container 
docker exec -it se_challenge_nginx-plus_1 nginx -s reload
```

### Add another web server instance with the hostname `nginx3` and add to the load balancing group `nginx_hello`

1. See example below, another service using `nginx-hello`. Copy and paste the provided service and relabel container name and hostname to `nginx3`
   
```yaml
version: '3.3'
services:
  nginx1:
      hostname: nginx1
      build: nginx-hello
      expose:
        - "80"
  nginx2:
      hostname: nginx2
      build: nginx-hello
      ports:
        - "80"
  # EDITS-START
  # Simply Add another server like so:    
  nginx3:
      hostname: nginx3
      build: nginx-hello
      ports:
        - "80"
  # EDITS-END      
  nginx-plus:
      hostname: nginx-plus
      build: nginx-plus
      links:
          - nginx1:nginx1
          - nginx2:nginx2
      volumes:
          - ./nginx-plus/etc/nginx:/etc/nginx
      ports:
          - 8080:8080
          - 80:80
          - 443:443
      restart: always
```
2. Add the new server, `nginx3` to the upstream, `nginx_hello`, group:

```nginx
# nginx-hello servers 
upstream nginx_hello {

    zone nginx_hello 64k;
    server nginx1:80;
    server nginx2:80;
    server nginx3:80; #<---Add the server here

    # Including keep alive connections are bonus points
    keepalive 32;
}
```