# NGINX Caching

## Introduction

NGINX can be used as an HTTP cache, delivering static content directly from memory and disk.  This can improve the response time and appearance of your web pages by providing this content much faster than waiting for the origin server to deliver it.  You have complete control over all parameters of HTTP caching, like the Headers, aging, refresh time, and other controls.  This high performance, low latency, scalable HTTP caching capability is the backbone of many of the world's largest Content Delivery Networks.  You will configure and test NGINX caching, with configurations you can use for your own website.

## Learning Objectives 

By the end of the lab you will be able to: 
 * Create a new lab environment for cache testing
 * Configure NGINX caching
 * Monitor and Log important cache metadata
 * Run performance tests

## Build an NGINX Cache lab environment

1. Inspect the `docker-compose.yml` file located in the /lab6 folder.  You see that we are still using NGINX Plus, but are changing the backend webserver to JuiceShop.  This is a simple web application that looks like a retail Juice shop, where customers can browse and shop the website for different drinks.  This Juiceshop website has many images and is an ideal candidate for Caching.

< Juice shop website image here>

```bash

...snip

# Juiceshop web application containers
  juice1:
      hostname: juice1
      container_name: juice1
      image: bkimminich/juice-shop            # Image from Docker Hub
      ports:
        - "3000"
  juice2:
      hostname: juice2
      container_name: juice2
      image: bkimminich/juice-shop
      ports:
        - "3000"
  juice3:
      hostname: juice3
      container_name: juice3
      image: bkimminich/juice-shop
      ports:
        - "3000"

```

1. Run the `docker-compose` command to download and run these 4 containers:

```bash
docker-compose up

```

Verify they are all up and running

```bash
docker ps -a

```

Should look something like:

```bash

<docker ps here>

```



## Configure NGINX to Load Balance JuiceShop

1. Create a new `upstreams-juice.conf` file in your `/etc/nginx/conf.d` folder, where you keep NGINX HTTP configuration files.  This will be your Upstream configuration.

    ```nginx
    # NGINX Basics, Plus Proxy to three upstream juiceshop servers
    # Chris Akker, Shouvik Dutta - Feb 2024
    #
    # nginx-juice servers 
    upstream nginx_juice {

        
        # Uncomment for Least Time Last Byte      
        least_time last_byte;

        # From Docker-Compose:
        server juice1:3000;
        server juice2:3000;
        server juice3:3000;

        # Uncomment for keepalive TCP connections to upstreams
        keepalive 16;

    }

    ```

1. Create a new `juice.example.com.conf` file in your `/etc/nginx/conf.d` folder, where you keep NGINX HTTP configuration files.  This will be your Server and Location blocks configuration.

```nginx
# juice.example.com HTTP
# NGINX Basics Workshop
# Feb 2024, Chris Akker, Shouvik Dutta
#
server {
    
    listen 80;      # Listening on port 80 on all IP addresses on this machine

    server_name juiceshop.example.com;   # Set hostname to match in request
    status_zone http://juiceshop.example.com;

    access_log  /var/log/nginx/juiceshop.example.com.log main;
    # access_log  /var/log/nginx/juiceshop.example.com.log main_ext;   Extended Logging
    error_log   /var/log/nginx/juiceshop.example.com_error.log notice;

    root /usr/share/nginx/html;       # Set the root folder for the HTML and JPG files

    location / {
        status_zone /;
        include includes/proxy_headers.conf;
        include includes/keepalive.conf;
        
        proxy_pass http://nginx_juice;        # Proxy AND load balance to a list of servers
    }

} 

```

1. Add `juiceshop.example.com` hostname to your /etc/hosts DNS file:

```bash
$ cat /etc/hosts

127.0.0.1       localhost juiceshop.example.com cafe.example.com cars.example.com www.example.com www2.example.com
```




<br/>

**This completes Lab 6.**

## References

- [NGINX Plus](https://docs.nginx.com/nginx/)
- [NGINX Admin Guide](https://docs.nginx.com/nginx/admin-guide/)
- [NGINX Technical Specs](https://docs.nginx.com/nginx/technical-specs/)

### Authors

- Chris Akker - Solutions Architect - Community and Alliances @ F5, Inc.
- Shouvik Dutta - Solutions Architect - Community and Alliances @ F5, Inc.

-------------

Navigate to ([Lab7](../lab7/readme.md) | [Main Menu](../readme.md))
