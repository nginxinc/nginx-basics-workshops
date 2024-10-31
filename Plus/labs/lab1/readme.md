# Build and Run NGINX Plus on Docker

## Introduction

You will build a Docker container running the Plus version of NGINX, which requires a subscription/license.  You will need a subscription license, using the TLS `nginx-repo.crt and nginx-repo.key` files.  These files provide access to the `NGINX Plus Repository` where the Plus binary files are located.  These are not publicly accessible, you must have a valid Certificate and Key for access.  This new NGINX Plus container will be used for the rest of the Lab exercises, while you explore and add Plus features and options to your environment.

## Learning Objectives

By the end of the lab you will be able to:

- Build an `NGINX Plus Docker` image
- Run this NGINX Plus image, adding it to your lab environment
- Test the Plus container
- Configure and Test the NGINX Plus Dashboard

NGINX Plus | Docker
:-------------------------:|:-------------------------:
![NGINX Plus](media/nginx-plus-icon.png)  |![Docker](media/docker-icon.png)

## So what is NGINX Plus?  

NGINX Plus is the `Commercial version of NGINX`, with additional Enterprise features on top of the base NGINX OSS build. Here is a Summary list of the Plus features:

- Dynamic reconfiguration reloads with no downtime
- Dynamic NGINX software updates with no downtime
- Dynamic DNS resolution and DNS Service discovery
- NGINX Plus API w/statistics and dashboard, over 240 metrics for TCP/HTTPS
- NGINX JavaScript Prometheus exporter libraries
- Dynamic Upstreams
- Key Value store
- Cache Purge API controls
- NGINX Clustering for High Availability
- JWT processing with OIDC for user authentication
- App Protect Firewall WAF

## Pre-Requisites

- You must have a license for NGINX Plus, see Lab0 Prerequisites for details
- You must have Docker installed and running
- You must have Docker-compose installed
- (Optional) You should have Visual Studio Code installed to work through the NGINX configuration files.
- (Optional) You should have the Visual Studio Thunder Client extension tool to make calls to NGINX Plus API.
- See `Lab0` for instructions on setting up your system for this Workshop

<br/>

## Build and Run NGINX Plus with Docker

Visual Studio Code | Docker
:-------------------------:|:-------------------------:
![VScode](media/vs-code-icon.png)  |![Docker](media/docker-icon.png)

1. Open the Workshop folder with Visual Studio Code, or an IDE / text editor of your choice, so you can read and edit the files provided.

1. Download and copy your NGINX Plus license files to your computer.  There are 3 files provided, you only need the `.crt and .key` files for this Workshop:

    - `nginx-repo.crt`, TLS certificate for Plus Repo access
    - `nginx-repo.key`, TLS key for Plus Repo access
    - nginx-repo.jwt, a JWT Token for the F5 container registry (not used in this Workshop).

    If you need an NGINX Plus Trial license, you can request one here:

    [NGINX Plus Trial](https://www.f5.com/trials/free-trial-nginx-plus-and-nginx-app-protect)

    >After submitting the Trial Request form, you will receive an Email in a few minutes with links to download your three license files.  The links are only good for a one-time download.  *Notice - you will also likely receive F5 sales and marketing emails.*

1. Copy your Plus TLS nginx-repo.* license files to the `lab1/nginx-plus/etc/ssl/nginx` folder within your workshop folder.  The nginx-repo files must be located in this exact folder for Docker compose to build the container properly.

    ```bash
    # Example
    cp /user/home/nginx-repo.* /user/home/nginx-basics-workshop/Plus/labs/lab1/nginx-plus/etc/ssl/nginx

    ```

1. Inspect the `docker-compose.yml` file, located in the /lab1 folder. Notice you start with building the NGINX-Plus container.  There are several folders that are mounted, and several TCP ports opened.

   ```bash
    nginx-plus:              # NGINX Plus Web / Load Balancer
        hostname: nginx-plus
        container_name: nginx-plus
        build: nginx-plus    # Build new container, using /nginx-plus/Dockerfile
        volumes:
            - ./nginx-plus/etc/nginx/conf.d:/etc/nginx/conf.d        # Copy these folders to container
            - ./nginx-plus/etc/nginx/includes:/etc/nginx/includes
            - ./nginx-plus/etc/nginx/nginx.conf:/etc/nginx/nginx.conf
        ports:
            - 80:80       # Open for HTTP
            - 443:443     # Open for HTTPS
            - 9000:9000   # Open for dashboard & api
        restart: always 
   ```

1. Also in the `docker-compose.yml` file you will run three other Docker NGINX webserver containers. These will be your upstream backend webservers for this workshop.

    ```bash
    web1:
      hostname: web1
      container_name: web1
      image: nginxinc/ingress-demo   # Image from Docker Hub
      ports:
        - "80"                       # Open for HTTP
        - "443"                      # Open for HTTPS
    web2:
        hostname: web2
        container_name: web2
        image: nginxinc/ingress-demo
        ports:
            - "80"
            - "433"
    web3:
        hostname: web3
        container_name: web3
        image: nginxinc/ingress-demo
        ports:
            - "80"
            - "443"
    ```

1. Ensure you are in the `lab1` folder.  Using a Terminal, or the Visual Studio Terminal, run Docker Compose to build and run all the above containers.

   ```bash
    cd lab1
    docker compose up --force-recreate -d

   ```
   If you encounter any errors during the Nginx Plus build process, or starting the containers, you must fix them before proceeding.

1. Verify all four containers are up and running:

    ```bash
    docker ps

    ```

    ```bash
    ###Sample output###
    CONTAINER ID   IMAGE                   COMMAND                  CREATED          STATUS          PORTS                                                                        NAMES
    717e1d8ff899   nginxinc/ingress-demo   "/docker-entrypoint.…"   13 seconds ago   Up 12 seconds   0.0.0.0:61344->80/tcp, 0.0.0.0:61343->443/tcp                                lab5-web3-1
    031354257db7   nginxinc/ingress-demo   "/docker-entrypoint.…"   13 seconds ago   Up 12 seconds   443/tcp, 0.0.0.0:61342->80/tcp, 0.0.0.0:61341->433/tcp                       lab5-web2-1
    a54a6e1fcda1   nginxinc/ingress-demo   "/docker-entrypoint.…"   13 seconds ago   Up 12 seconds   0.0.0.0:61346->80/tcp, 0.0.0.0:61345->443/tcp                                lab5-web1-1
    8dff0d9e7dce   lab1-nginx-plus         "nginx -g 'daemon of…"   13 seconds ago   Up 12 seconds   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:9000->9000/tcp, 8080/tcp   lab5-nginx-plus-1
    ```

1. Test curl access to your NGINX Plus container.

    ```bash
    curl http://localhost

    ```
    You should see the Nginx Welcome page.

    Now also test with Chrome or a browser, you should see the same page.

    ![NGINX Welcome](media/lab1_nginx-welcome.png)

### Explore the NGINX Plus container

In this section, you explore and learn about various Nginx and Linux commands used to configure Nginx and see what is happening in your container.

1. Using a second Terminal window, log into the NGINX Plus container with the Docker Exec command:

    ```bash
    docker exec -it nginx-plus /bin/bash

    ```

1. Run some commands inside the NGINX Plus Container:

    ```bash
    # Check NGINX help page
    nginx -h

    ```

    ```bash
    ##Sample Output##
    nginx version: nginx/1.25.3 (nginx-plus-r31)
    Usage: nginx [-?hvVtTq] [-s signal] [-p prefix]
             [-e filename] [-c filename] [-g directives]

    Options:
      -?,-h         : this help
      -v            : show version and exit
      -V            : show version and configure options then exit
      -t            : test configuration and exit
      -T            : test configuration, dump it and exit
      -d            : dancing - no help available
      -q            : suppress non-error messages during configuration testing
      -s signal     : send signal to a master process: stop, quit, reopen, reload
      -p prefix     : set prefix path (default: /etc/nginx/)
      -e filename   : set error log file (default: /var/log/nginx/error.log)
      -c filename   : set configuration file (default: /etc/nginx/nginx.conf)
      -g directives : set global directives out of configuration file

    ```

    ```bash
    # What version of Nginx is running:
    nginx -v

    ```

    ```bash
    ##Sample Output##
    nginx version: nginx/1.25.5 (nginx-plus-r32-p1)  # Notice the -plus-rXX label

    ```

    ```bash
    # What are all modules and configs settings of NGINX Plus:
    nginx -V

    ```

    ```bash
    ##Sample Output##
    nginx version: nginx/1.25.3 (nginx-plus-r31)
    built by gcc 9.4.0 (Ubuntu 9.4.0-1ubuntu1~20.04.2) 
    built with OpenSSL 1.1.1f  31 Mar 2020
    TLS SNI support enabled
    configure arguments: --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-http_v3_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --build=nginx-plus-r31 --mgmt-id-path=/var/lib/nginx/nginx.id --with-http_auth_jwt_module --with-http_f4f_module --with-http_hls_module --with-http_proxy_protocol_vendor_module --with-http_session_log_module --with-mgmt --with-stream_mqtt_filter_module --with-stream_mqtt_preread_module --with-stream_proxy_protocol_vendor_module --with-cc-opt='-g -O2 -fdebug-prefix-map=/data/builder/debuild/nginx-plus-1.25.3/debian/debuild-base/nginx-plus-1.25.3=. -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie'

    ```

    ```bash
    # Check for nginx packages installed
    dpkg-query -l | grep nginx
    
    dpkg -s nginx-plus

    ```

    ```bash
    ##Sample Output##
    ii  nginx-plus                 31-1~focal                   amd64        NGINX Plus, provided by Nginx, Inc.

    Package: nginx-plus
    Status: install ok installed
    Priority: optional
    Section: httpd
    Installed-Size: 7062
    Maintainer: NGINX Packaging <nginx-packaging@f5.com>
    Architecture: amd64
    Version: 31-1~focal
    Replaces: nginx, nginx-core, nginx-plus-debug
    Provides: httpd, nginx, nginx-plus-r31
    Depends: libc6 (>= 2.28), libcrypt1 (>= 1:4.1.0), libpcre2-8-0 (>= 10.22), libssl1.1 (>= 1.1.1), zlib1g (>= 1:1.1.4), lsb-base (>= 3.0-6)
    Recommends: logrotate
    Conflicts: nginx, nginx-common, nginx-core
    Conffiles:
     /etc/init.d/nginx 0b8cb35c30e187ff9bdfd5d9e7d79631
    /etc/init.d/nginx-debug ed610161bfa49f021f5afa483a10eac5
    /etc/logrotate.d/nginx a4da44b03e39926b999329061770362b
    /etc/nginx/conf.d/default.conf 5e054c6c3b2901f98e0d720276c3b20c
    /etc/nginx/fastcgi_params 4729c30112ca3071f4650479707993ad
    /etc/nginx/mime.types 754582375e90b09edaa6d3dbd657b3cf
    /etc/nginx/nginx.conf 563e30e020178f0db80bd2a87d6232a6
    /etc/nginx/scgi_params df8c71e25e0356ffc539742f08fddfff
    /etc/nginx/uwsgi_params 88ac833ee8ea60904a8b3063fde791de
    Description: NGINX Plus, provided by Nginx, Inc.
     NGINX Plus extends NGINX open source to create an enterprise-grade Application Delivery Controller, Accelerator and Web Server. Enhanced features include: Layer 4 and Layer 7 load balancing with health checks,session persistence and on-the-fly configuration; Improved content caching;Enhanced status and monitoring information; Streaming media delivery.
    Homepage: https://www.nginx.com/

    ```

    ```bash
    # What nginx processes are running?
    ps aux |grep nginx

    ```

    ```bash
    ##Sample Output##
    root         1  0.0  0.0  10544  7040 ?        Ss   18:27   0:00 nginx: master process nginx -g daemon off;
    nginx        7  0.0  0.0  92924  4312 ?        S    18:27   0:00 nginx: worker process
    root        50  0.0  0.0   3312  1792 pts/0    S+   19:00   0:00 grep --color=auto nginx

    ```

    ```bash
    # Which TCP Ports are being used by NGINX ?
    netstat -alpn

    ```

    ```bash
    ##Sample output##
    Active Internet connections (servers and established)
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
    tcp        0      0 127.0.0.11:41055        0.0.0.0:*               LISTEN      -                   
    tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      1/nginx: master pro 
    tcp        0      0 192.168.32.5:57614      185.125.190.36:80       TIME_WAIT   -                   
    udp        0      0 127.0.0.11:38617        0.0.0.0:*                           -                   
    Active UNIX domain sockets (servers and established)
    Proto RefCnt Flags       Type       State         I-Node   PID/Program name     Path
    unix  3      [ ]         STREAM     CONNECTED     1446456  1/nginx: master pro  
    unix  3      [ ]         STREAM     CONNECTED     1446455  1/nginx: master pro

    ```

    ```bash
    # Look around the nginx configuration folders
    ls -l /etc/nginx

    ls -l /etc/nginx/conf.d

    ```

    ```bash
    # Test the current NGINX configuration
    nginx -t

    ```

    ```bash
    ##Sample Output##
    nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    nginx: configuration file /etc/nginx/nginx.conf test is successful

    ```

    ```bash
    # Reload Nginx - checks your new config and reloads Nginx
    nginx -s reload

    ```

    ```bash
    # Display the entire NGINX configuration, includes all files
    nginx -T

    ```

    ```bash
    # Check the Nginx access log
    tail -f /var/log/nginx/access.log

    ```

    ```bash
    # Check the Nginx error log
    tail -f /var/log/nginx/error.log

    ```

    **You will use most of these Nginx and Linux commands in the next Lab exercises so you can see how they work.**

    *NOTE: When you are done looking around, do not close this Second Terminal, you will use it for the next exercises to control and watch Nginx.*

<br/>

## NGINX Plus Live Monitoring Dashboard

![NGINX Plus](media/nginx-plus-icon.png) 

In this section, you will enable the NGINX Plus status Dashboard and watch it for status changes and metrics while you add new configerations and run various tests on NGINX.

The NGINX Plus Dashboard and statistics API provide over 240 metrics about the request and responses flowing through NGINX Plus. This is a great feature to allow you to watch and triage any potential issues with NGINX Plus as well as any issues with your backend applications. Some of metrics provided include the following:

- TCP throughput and connections
- HTTP request and response metrics and all status codes
- Virtual Server and Location context metrics
- HTTP Upstream context metrics
- TCP Upstream context metrics
- Healthcheck success/failure counters
- TLS handshakes, sessions and reuse
- NGINX caching metrics
- DNS resolver
- NGINX clustering
- NGINX Worker Metrics
- Ratelimit Metrics

All of these metrics are available via NGINX Plus API as a JSON object making it easy to import these stats/metrics into your choice of Monitoring tools.  You will do this in a lab exercise.

1. Using Visual Studio, create a new file called `/etc/nginx/conf.d/dashboard.conf`.  Copy/paste the Nginx config provided.

    ```nginx
    server {
        # Conventional port for the NGINX Plus API is 8080
        listen 9000;
        access_log off; # reduce noise in access logs

        location /api/ {
        # Enable in read-write mode
        api write=on;
        }
        # Conventional location of the NGINX Plus dashboard
        location = /dashboard.html {
            root /usr/share/nginx/html;
        }

        # Redirect requests for "/" to "/dashboard.html"
        location / {
            return 301 /dashboard.html;
        }
    }

    ```
    Notice the following configuration parameters:
    - The Dashboard is listening on port 9000, not port 80.
    - The URL is /dashboard.html, using the local folder /usr/share/nginx/html
    - The full URL will be [http://localhost:9000/dashboard.html](http://localhost:9000/dashboard.html)

1. Test your Nginx configuration and reload Nginx, using the Terminal logged into the Nginx Plus container:

   ```bash
   nginx -t
   nginx -s reload

   ```

1. Test the URL in Chrome at `http://localhost:9000/dashboard.html`.

    You should see the Dashboard.  Note:  There is not much yet to see, because you have not configured anything yet!  

    ![NGINX Dashboard](media/lab1_dashboard.png)

    Click on the `Workers tab` in the upper right corner, you can see the stats like process id, active connections, idle connections, total request, requests per second for each Nginx worker process.

    ![NGINX Workers](media/lab1_dashboard-workers.png)


**This completes Lab 1.**

## References

- [NGINX Plus](https://docs.nginx.com/nginx/)
- [NGINX Admin Guide](https://docs.nginx.com/nginx/admin-guide/)
- [NGINX Technical Specs](https://docs.nginx.com/nginx/technical-specs/)
- [NGINX Plus API Module](https://nginx.org/en/docs/http/ngx_http_api_module.html)
- [NGINX Plus Live Monitoring](https://docs.nginx.com/nginx/admin-guide/monitoring/live-activity-monitoring/)
- [NGINX Dashboard Demo](https://demo.nginx.com/)

### Authors

- Chris Akker - Solutions Architect - Community and Alliances @ F5, Inc.
- Shouvik Dutta - Solutions Architect - Community and Alliances @ F5, Inc.

-------------

Navigate to ([Lab6](../lab6/readme.md) | [Main Menu](../readme.md))
