# NGINX-Basics

Implement NGINX Plus as an HTTP and HTTPS (SSL terminating) load balancer for two or more HTTP services

### Goals 

 * Provide a variety of NGINX Plus demonstrations
 * Provide examples of NGINX configurations best practices
 * Give you a feel for what it is like to work with NGINX Plus

## The Demo environement

This demo has three containers, a NGINX Plus ADC/load balancer, `nginx-plus`, and webservers, `nginx1`, `nginx2` and `nginx3`:

 * **NGINX Plus** `(Latest)` based on ubuntu 18.04 (and a sample centos 7 Dockerfile is provided). [NGINX Plus Documentation](https://docs.nginx.com/nginx/), and [resources](https://www.nginx.com/resources/) and [blog](https://www.nginx.com/blog/) is your best source of information for technical help. Detailed examples are found on the internet too!

 * **NGINX OSS** `(Latest)` is based on [**nginx-hello**](https://github.com/nginxinc/NGINX-Demos/tree/master/nginx-hello). A NGINX webserver that serves a simple page containing its hostname, IP address and port as wells as the request URI and the local time of the webserver.

### Topology

The base Docker Compose environment the lab is build on

```
                                             (nginx-hello upstream: nginx1:80, nginx2:80)
                      +---------------+                        
                      |               |       +-----------------+
+-------------------->|               |       |                 |
www.example.com       |               +------>|      nginx1     |
HTTP/Port 80          |               |       |  (nginx-hello)  |
                      |               |       |                 |
                      |               |       +-----------------+
+-------------------->|               |
www2.example.com      |               |       +-----------------+
HTTP-HTTPS redirect   |  nginx-plus   |       |                 |
HTTP/Port 80          |     (ADC)     +------>|     nginx2      |                     
                      |               |       |  (nginx-hello)  |
+-------------------->|               |       |                 |
www2.example.com      |               |       +-----------------+
HTTPS/Port 443        |               |             
                      |               |       +-----------------+         
                      |               |       |                 |
                      |               +------>|     nginx3      | 
                      |               |       |  (nginx-hello)  |
                      |               |       |                 |
                      |               |       +-----------------+
                      |               |
                      |               |       (dynamic upstream - empty)
+-------------------->|               |       +-----------------+         
NGINX Dashboard/      |               |       |                 |
API                   |               +------>|                 |
HTTP/Port 8080        |               |       |        *        |
                      |               |       |                 |
                      |               |       +-----------------+
                      +---------------+                                                                                     
```

## File Structure

```
/
├── etc/
│    ├── nginx/
│    │    ├── conf.d/ # ADD your HTTP/S configurations here
│    │    │   ├── example.com.conf............HTTP www.example.com Virtual Server configuration
│    │    │   ├── www2.example.com.conf.......HTTPS www2.example.com Virtual Server configuration
│    │    │   ├── upstreams.conf..............Upstream configurations
│    │    │   ├── stub_status.conf............NGINX Open Source basic status information available http://localhost/nginx_status only
│    │    │   └── status_api.conf.............NGINX Plus Live Activity Monitoring available on port 8080 - [Source](https://gist.github.com/nginx-gists/│a51 341a11ff1cf4e94ac359b67f1c4ae)
│    │    ├── includes
│    │    │    ├── add_headers/ # Headers to attach to client response
│    │    │    │   └── security.conf_ ........Recommended response headers for security
│    │    │    ├── error_pages/ # Custom Error Pages
│    │    │    │   ├── error_pages.conf.......NGINX configurations for custom error pages
│    │    │    │   ├── http403.conf_ .........Example HTTP 403 custom error pages
│    │    │    │   └── http404.conf_ .........Example HTTP 404 custom error pages
│    │    │    ├── proxy_headers/ # Headers to attach to upstream request
│    │    │    │   ├── keepalive.conf.........Recommended HTTP keepalives headers for performance
│    │    │    │   └── proxy_headers.conf.....Recommended request headers for request routing and logging
│    │    │    └── ssl # TLS Configurations examples
│    │    │        ├── ssl_intermediate.conf..Recommended SSL configuration for General-purpose servers with a variety of clients, recommended for almost all systems
│    │    │        ├── ssl_a+_strong.conf.....Recommended SSL configuration for Based on SSL Labs A+ (https://www.ssllabs.com/ssltest/)
│    │    │        ├── ssl_modern.conf........Recommended SSL configuration for Modern clients: TLS 1.3 and don't need backward compatibility
│    │    │        └── ssl_old.conf...........SSL configuration for compatiblity ith a number of very old clients, and should be used only as a last resort
│    │    ├── stream.conf.d/ #ADD your TCP and UDP Stream configurations here
│    │    └── nginx.conf .....................Main NGINX configuration file with global settings
│    └── ssl/
│          ├── nginx/ # NGINX Plus licenses
│          │   ├── nginx-repo.crt.............NGINX Plus repository certificate file (Use your evaluation crt file)
│          │   └── nginx-repo.key.............NGINX Plus repository key file (Use your evaluation key file)
|          ├── dhparam/ # Diffie–Hellman (DH) key exchange files
|          │    ├── 2048
|          │    │    └──nginx-repo.crt........2048 bit DH parameters
|          │    └── 4096
|          │        └──nginx-repo.crt.........4096 bit DH parameters
│          ├── example.com.crt................Self-signed wildcard certifcate for testing (*.example.com)
│          └── example.com.key................Self-signed private key for testing
└── var/
     ├── cache/
     │    └── nginx/ # Designated path for storing cached content
     └── lib/
          └── nginx/
               └── state/ # The recommended path for storing state files on Linux distributions
```

## Prerequisites:

1. NGINX evaluation license file. You can get it from [here](https://www.nginx.com/free-trial-request/)

2. A Docker host. With [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/)

3. **Optional**: The demo uses hostnames: `www.example.com` and `www2.example.com`. For host name resolution you will need to add hostname bindings to your hosts file:

For example on Linux/Unix/MacOS the host file is `/etc/hosts`

```bash
# NGINX Plus SE challenge demo (local docker host)
127.0.0.1 www.example.com www2.example.com
```

> **Note:**
> DNS resolution between containers is provided by default using a new bridged network by docker networking and
> NGINX has been preconfigured to use the Docker DNS server (127.0.0.11) to provide DNS resolution between NGINX and
> upstream servers

## Build and run the demo environment

Provided the Prerequisites have been met before running the stpes below, this is a **working** environment. 

### Build the demo

In this demo we will have a one NGINX Plus ADC/load balancer (`nginx-plus`) and two NGINX OSS webserver (`nginx1` and `nginx2`)

Before we can start, we need to copy our NGINX Plus repo key and certificate (`nginx-repo.key` and `nginx-repo.crt`) into the directory, `nginx-plus/etc/ssl/nginx/`, then build our stack:

```bash
# Enter working directory
cd nginx-basics

# Make sure your Nginx Plus repo key and certificate exist here
ls nginx-plus/etc/ssl/nginx/nginx-*
nginx-repo.crt              nginx-repo.key

# Downloaded docker images and build
docker-compose pull
docker-compose build --no-cache
```

-----------------------
> See other other useful [`docker`](docs/useful-docker-commands.md) and [`docker-compose`](docs/useful-docker-compose-commands.md) commands
-----------------------

#### Start the Demo stack:

Run `docker-compose` in the foreground so we can see real-time log output to the terminal:

```bash
docker-compose up
```

Or, if you made changes to any of the Docker containers or NGINX configurations, run:

```bash
# Recreate containers and start demo
docker-compose up --force-recreate
```

**Confirm** the containers are running. You should see three containers running:

```bash
docker ps
CONTAINER ID        IMAGE                           COMMAND                  CREATED             STATUS              PORTS                                                              NAMES
7ed735c809b8        nginx-basics_nginx-plus   "nginx -g 'daemon of…"   5 seconds ago       Up 4 seconds        0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:8080->8080/tcp   nginx-basics_nginx-plus_1
4910dca52bb7        nginx-basics_nginx2       "nginx -g 'daemon of…"   6 seconds ago       Up 5 seconds        0.0.0.0:32815->80/tcp                                              nginx-basics_nginx2_1
6c9a92298116        nginx-basics_nginx1       "nginx -g 'daemon of…"   6 seconds ago       Up 5 seconds        80/tcp                                                             nginx-basics_nginx1_1
```

The demo environment is ready in seconds. You can access the `nginx-hello` demo website on **HTTP / Port 80** ([`http://localhost`](http://localhost) or [http://www.example.com](http://example.com)) and the NGINX API on **HTTP / Port 8080** ([`http://localhost:8080`](http://localhost))

You should also be able to access the `nginx-hello` demo, expecting the host header `www2.example.com`, over **HTTPS / Port 443** (i.e. [`https://www2.example.com`](https://www2.example.com))

> If any of the three expected containers are not running, or you **suspect the environement is broken**:
> **STOP** and contact your NGINX contact for help :-)

## The SE Challenge 

### Technical Requirements 

See the Minimum requirements and Extra Credit requirements below. 

Cloning your repository and typing “docker-compose up” should be only steps to get your demo environement up and running

#### The following is the provided base setup:

* Three Nodes in total: one NGINX load balancer, two HTTP services running [nginx-hello](https://github.com/nginxinc/NGINX-Demos/tree/master/nginx-hello) 
* A HTTP Service for `www.example.com`
* A Upstream group named `nginx_hello` containing two webservers, `nginx1` and `nginx2` 
* Client traffic for `www.example.com` and default HTTP port 80 traffic is load balanced using the default load balancing algorithm, round-robin, across the two [nginx-hello](https://github.com/nginxinc/NGINX-Demos/tree/master/nginx-hello) HTTP services 
* A empty upstream group named `dynamic` 
* [NGINX Plus Live Activity Monitoring](https://www.nginx.com/products/nginx/live-activity-monitoring/) on port 8080

#### Minimum requirements

As you complete the tasks think about:
 * How did you arrive at your solution? (troubleshooting process, challenges, resources used, etc.)
 * Can you articulate what is happening to a techical and non-techical audience?
 * What value does the following feature provide? and what use-cases would benefit from these capabilites?

The following is minimum addtions to be configured:

* HTTPS service for `www2.example.com` traffic over Port 443 (You can use the self-signed certificates provided). Configure NGINX PLus SSL termination on the load balancer and proxy upstream servers over HTTP, i.e. `Client --HTTPS--> NGINX (SSL termination) --HTTP--> webserver`
    * What are some TLS Best practices that should be considered here?
* HTTP to HTTPS redirect service for `www2.example.com`, i.e. `Client --HTTP--> NGINX (redirect) --HTTPS--> NGINX (SSL termination) --HTTP--> webserver`
* Enable [keepalive connections](https://www.nginx.com/blog/http-keepalives-and-web-performance/) to upstream servers. 
    * How would you test and confirm this has been enabled?

#### Extra Credits  

Enable any of the following features on the NGINX Plus load balancer for extra credits:

* Enable a Active HTTP Health Check: Periodically check the health of upstream servers by sending a custom health‑check requests to each server and verifying the correct response. e.g. check for a `HTTP 200` response and `content type: text/html`
* Enable a HTTP load balancing algorithm methods **other than the default**, round-robin  
* Provide the [`curl`](https://ec.haxx.se/http-cheatsheet.html) (or similar tool) command to add and remove server from the NGINX upstream named `dynamic` via the NGINX API. 
* Create a `HTTP 301` URL redirect for `/old-url` to `/new-url`
* Enable Proxy caching for **image files only**. Use the Cache folder provisioned on `/var/cache/nginx`, i.e. set `proxy_cache_path` to `/var/cache/nginx`. Validate the test image http://www.example.com/smile.png is cached on NGINX
* Enable any Session persistence method to routes all requests in a given use session to the same upstream server
* Provide the command to execute a the NGINX command on the a running container, e.g.  `nginx -t` to check nginx config file and `nginx -s reload` to Reload the configuration file
* Add another web server instance in the `docker-compose.yml` file, using the same [nginx-hello](https://github.com/nginxinc/NGINX-Demos/tree/master/nginx-hello), with the hostname, `nginx3`, and add the new server to the upstream group, `nginx_hello`

## Q&A 

* **This does not need to be done in a vacuum**.  You can always ask questions at any step along the way.  Clarity is important so you will not be penalized for asking any questions.