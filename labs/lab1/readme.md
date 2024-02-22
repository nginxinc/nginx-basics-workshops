
# Build and Run NGINX Opensource on Docker

## Introduction

In this lab, you will build a test lab environment using NGINX and Docker.  This will require that you build and run NGINX Opensource as a `Web Server` in a Docker container.  Then you will test and verify the web server functions.  This NGINX container will be used as a learning platform for several labs in this Workshop.  It is important to build and run this NGINX web server container correctly to complete the exercises and receive the most benefit from the Workshop.

NGINX OSS | Docker
:-------------------------:|:-------------------------:
![NGINX OSS](media/nginx-icon.png)  |![Docker](media/docker-icon2.png)
  
## Learning Objectives

By the end of the lab you will be able to:

- Introduction to the History and Architectrure of NGINX
- Build an `NGINX Opensource Docker` image
- Build your Workshop enviroment with Docker Compose
- Run the NGINX OSS image
- Verify initial container build and NGINX tests

## Pre-Requisites

- You must have Docker installed and running
- You must have Docker-compose installed
- See `Lab0` for instructions on setting up your system for this Workshop
- Familiarity with basic Linux commands and commandline tools
- Familiarity with basic Docker concepts and commands
- Familiarity with basic HTTP protocol

## The History and Architecture of NGINX

NGINX | NGINX
:-------------------------:|:-------------------------:
![NGINX OSS](media/nginx-icon.png)|![NGINX Logo](media/nginx-logo.png)

NGINX was written in 2002 by Igor Sysov while he was working at rambler.ru, a web company providing Internet Search content.  As Rambler continued to grow, Igor kept hitting the practical limit of 10,000 simultaneous HTTP requests with Apache HTTP server.  The only way to handle more traffic was to buy and run more servers.  So he wrote NGINX to solve the `C10k concurrency problem` - how do you handle more than 10,000 concurrent requests on a single Linux server.  

Igor created a new TCP connection and request handling concept called the `NGINX Worker`.  The Workers are Linux processes that continually wait for incoming TCP connections, and immediately handle the Request, and deliver the Response.  It is based on event-driven computer program logic written in the `native C programming language`, which is well-known for its speed and power.  Importantly, NGINX Workers can use any CPU, and can scale in performance as the compute hardware scales up, providing a nearly linear performance curve.  There are many articles written and available about this NGINX Worker architecture if you are interested in reading more about it.  

Another architecural concept in NGINX worth noting, is the `NGINX Master` process.  The master process interacts with the Linux OS, controls the Workers, reads and validates config files before using them, writes to error and logging files, and performs other NGINX and Linux management tasks.  It is considered the Control plane process, while the Workers are considered the Data plane processes.  The `separation of Control functions from Data handling functions` is also very beneficial to handling high concurrency, high volume web traffic.

NGINX also uses a `Shared Memory model`, where common elements are equally accessed by all Workers.  This reduces the overall memory footprint considerably, making NGINX very lightweight, and ideal for containers and other small compute environments.  You can literally run NGINX off a legacy floppy disk!

In the `NGINX Architectural` diagram below, you can see these different core components of NGINX, and how they relate to each other.  You will notice that Control and Management type functions are separate and independent from the Data flow functions of the Workers that are handling the traffic.  You will find links to NGINX core architectures and concepts in the References section.

>> It is this unique architecture that makes NGINX so powerful and efficient.

![NGINX Architecture](media/lab1_nginx-architecture.png)

- In 2004, NGINX was released as open source software (OSS).  It rapidly gained popularity and has been adopted by millions of websites.

- In 2013, NGINX Plus was released, providing additional features and Commercial Support for Enterprise customers. 

## Build the Workshop Environment with Docker Compose

For this first lab you will build and run 1 Docker container, used as an NGINX web server.  You will use Docker Compose to build the image, run it, and shut it down when you are finished.

### Build and Run NGINX OSS with Docker

Visual Studio Code | Docker Compose | GitHub
:-------------------------:|:-------------------------:|:-------------------------:
![Visual Studio](media/vs-code-icon.png)|![NGINX Logo](media/docker-icon2.png)|![Github Logo](media/github-icon.png)

1. **(Optional):** If you are using your own computer, create a new folder to hold all the Workshop materials. Then clone the Workshop's Github reposititory to this folder:

    ```bash
    git clone https://github.com/nginxinc/nginx-basics-workshops.git
    
    ```

1. Open the Workshop folder with `Visual Studio Code`, or an IDE / text editor of your choice, so you can read and edit the files provided.

1. Inspect the Dockerfile, located in the `labs/lab1/nginx-oss` folder.  Notice the `FROM` directive uses the `NGINX Alpine` base image, and also the `RUN apk add` command, which installs additional tool libraries in the image.  These tools are needed for copy/edit of files, and to run various tests while using the container in the exercises.

    ```bash
    FROM nginx:mainline-alpine                                                     # use the Alpine base image
    RUN apk add --no-cache curl ca-certificates bash bash-completion jq wget vim   # Add common tools

    ```

1. Inspect the `docker-compose.yml` file, located in the `labs/lab1` folder.  Notice you are building the NGINX-OSS webserver container, (using the modified `/nginx-oss/Dockerfile` from the previous step).  

    ```bash
    ...
    nginx-oss:                  # NGINX OSS Load Balancer
        hostname: nginx-oss
        container_name: nginx-oss
        build: nginx-oss        # Build new container, using /nginx-oss/Dockerfile
        volumes:                # Copy this file to container
            - ./nginx-oss/etc/nginx/conf.d/stub_status.conf:/etc/nginx/conf.d/stub_status.conf   
        ports:
            - 9000:9000         # Open for stub status page
            - 80:80             # Open for HTTP
            - 443:443           # Open for HTTPS
        restart: always

    ```

1. Run Docker Compose to build and run your NGINX OSS container:

    ```bash
    cd lab1
    docker-compose up --force-recreate

    ```

    ```bash
     ##Sample output##
     Running 2/2
     Container nginx-oss            Created               0.1s
     Network lab1_default           Created               0.1s

    ```

1. Verify your container is running:

    ```bash
    docker ps -a
    ```

    ```bash
     ##Sample output##
     CONTAINER ID   IMAGE                   COMMAND                  CREATED          STATUS          PORTS                                                              NAMES
     28df738bd4bb   lab1-nginx-oss          "/docker-entrypoint.…"   34 minutes ago   Up 34 minutes   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:9000->9000/tcp   nginx-oss

    ```

1. Test access to the NGINX default web page:

    ```bash
    curl -I http://localhost
    ```

    ```bash
     ##Sample output##
     HTTP/1.1 200 OK
     Server: nginx/1.25.3
     Date: Thu, 25 Jan 2024 23:55:47 GMT
     Content-Type: text/html
     Content-Length: 615
     Last-Modified: Tue, 24 Oct 2023 16:48:50 GMT
     Connection: keep-alive
     ETag: "6537f572-267"
     Accept-Ranges: bytes

    ```

1. Test again, this time using your browser:

    Launch your browser, go to [http://localhost](http://localhost)

    You should see the Welcome to nginx web page.

    ![NGINX Welcome](media/lab1_nginx-welcome.png)

1. Test access to the `NGINX stub status` page.  This page provides basic metrics for NGINX TCP connections and HTTP requests.

    ```bash
    curl http://localhost:9000/basic_status
    ```

    ```bash
     ##Sample Output##
     Active connections: 1
     server accepts handled requests
     23 23 37
     Reading: 0 Writing: 1 Waiting: 0

    ```

    Try it in a browser, copy/paste the previous URL:

    ![NGINX Status](media/lab1_nginx-status.png)

1. NGINX under the Hood.  Log into the NGINX-OSS container with Docker Exec:

    ```bash
     docker exec -it nginx-oss /bin/bash
    ```

1. Run some commands inside the NGINX-OSS Container:

    ```bash
     # Look around the nginx folders
     ls -l /etc/nginx

     ls -l /etc/nginx/conf.d
    ```

    ```bash
     # Check for nginx packages installed
     apk info -vv |grep nginx
    ```

    ```bash
     ##Sample Output##
     nginx-1.25.4-r1 - High performance web server
     nginx-module-geoip-1.25.4-r1 - nginx GeoIP dynamic modules
     nginx-module-image-filter-1.25.4-r1 - nginx image filter dynamic module
     nginx-module-njs-1.25.4.0.8.3-r1 - nginx njs dynamic modules
     nginx-module-xslt-1.25.4-r1 - nginx xslt dynamic module
    ```

    ```bash
     # What nginx processes are running?
     ps aux |grep nginx
    ```

    ```bash
     ##Sample Output##
     1 root      0:00 nginx: master process nginx -g daemon off;
     30 nginx     0:00 nginx: worker process
     31 nginx     0:00 nginx: worker process
     ...
     50 root      0:00 grep nginx

    ```

    ```bash
     # Check Linux TOP for resource usage
     top -n 1 
    ```

    ```bash
     ##Sample Output##
     Mem: 2767872K used, 5267076K free, 10988K shrd, 233608K buff, 1636236K cached
     CPU:   0% usr   0% sys   0% nic 100% idle   0% io   0% irq   0% sirq
     Load average: 0.00 0.00 0.00 1/601 54
       PID  PPID USER     STAT   VSZ %VSZ CPU %CPU COMMAND
        31     1 nginx    S     9372   0%   8   0% nginx: worker      process
        30     1 nginx    S     9372   0%   1   0% nginx: worker      process
        ...
         1     0 root     S     8908   0%   4   0% nginx: master      process nginx -g daemon off;
        42     0 root     S     3404   0%   5   0% /bin/bash
        54    42 root     R     1600   0%   6   0% top -n 1

    ```

    ```bash
     # Which TCP Ports are being used by NGINX ?
     netstat -alpn
    ```

    ```bash
     ##Sample output##
     Active Internet connections (servers and established)
     Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/     Program name    
     tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      1/     nginx: master pro
     tcp        0      0 127.0.0.11:44421        0.0.0.0:*               LISTEN      -
     tcp        0      0 0.0.0.0:9000            0.0.0.0:*               LISTEN      1/     nginx: master pro
     tcp        0      0 :::80                   :::*                    LISTEN      1/     nginx: master pro
     udp        0      0 127.0.0.11:54300        0.0.0.0:*                           -
     Active UNIX domain sockets (servers and established)
     Proto RefCnt Flags       Type       State         I-Node PID/Program name    Path
     unix  3      [ ]         STREAM     CONNECTED     13223907 1/nginx: master pro 
     unix  3      [ ]         STREAM     CONNECTED     13223892 1/nginx: master pro 
     ...

    ```

    ```bash
     # Ask NGINX for help, (with NGINX, not dancing)
     nginx -h
    ```

    ```bash
     ##Sample output##
     nginx version: nginx/1.25.3
     Usage: nginx [-?hvVtTq] [-s signal] [-c filename] [-p prefix] [-g directives]
 
     Options:
     -?,-h         : this help
     -v            : show version and exit
     -V            : show version and configure options then exit
     -t            : test configuration and exit
     -T            : test configuration, dump it and exit
     -q            : suppress non-error messages during configuration testing
     -s signal     : send signal to a master process: stop, quit, reopen, reload
     -p prefix     : set prefix path (default: /etc/nginx/)
     -e filename   : set error log file (default: /var/log/nginx/error.log)
     -c filename   : set configuration file (default: /etc/nginx/nginx.conf)
     -g directives : set global directives out of configuration file
     -d dancing    : no help available

    ```

    ```bash
     # Verify what version of NGINX is running, which modules are included
     nginx -V
    ```

    ```bash
     ##Sample output##
     nginx version: nginx/1.25.4
     built by gcc 12.2.1 20220924 (Alpine 12.2.1_git20220924-r10) 
     built with OpenSSL 3.1.3 19 Sep 2023 (running with OpenSSL 3.1.4 24 Oct 2023)
     TLS SNI support enabled
     configure arguments: --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --with-perl_modules_path=/usr/lib/perl5/vendor_perl --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-http_v3_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-Os -Wformat -Werror=format-security -g' --with-ld-opt='-Wl,--as-needed,-O1,--sort-common -Wl,-z,pack-relative-relocs'

    ```

    ```bash
     # Test the current NGINX configuration
     nginx -t
    ```

    ```bash
     ##Sample output##
     nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
     nginx: configuration file /etc/nginx/nginx.conf test is successful

    ```

    ```bash
     # Display the entire NGINX configuration, includes all files.
     more nginx -T
    ```

1. When you are done looking around, Exit the container.

    ```bash
    exit
    ```

1. Check the logs for the NGINX-OSS container.

    ```bash
    docker logs nginx-oss
    ```

    ```bash
     ##Sample output##
     docker stuff
     ...
     /docker-entrypoint.sh: Configuration complete; ready for start up
     172.17.0.1 - - [18/Jun/2019:18:41:32 +0000] "GET / HTTP/1.1" 200  612 "-" "curl/7.47.0" "-"
     172.17.0.1 - - [18/Jun/2019:18:41:45 +0000] "HEAD / HTTP/1.1" 200  0 "-" "curl/7.47.0" "-"
     35.260.46.11 - - [18/Jun/2019:18:46:13 +0000] "GET / HTTP/1.1" 200  612 "-" "Mozilla/5.0 zgrab/0.x" "-"
     127.0.0.1 - - [18/Jun/2019:19:07:12 +0000] "GET / HTTP/1.1" 200  612 "-" "curl/7.64.0" "-"
     127.0.0.1 - - [18/Jun/2019:19:07:16 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.64.0" "-"

    ```

>>**Congratulations, you are now a member of Team NGINX !**

![NGINX Logo](media/nginx-tshirt.png)

>If you are finished with all the testing of the NGINX web server container, you can use Docker Compose to shut down your test environment:

```bash
docker-compose down
```

```bash
##Sample output##
Running 2/2
Container nginx-oss          Removed                            
Network lab1_default         Removed

```

**This completes Lab1.**

<br/>

## References:

- [NGINX OSS](https://nginx.org/en/docs/)
- [NGINX Admin Guide](https://docs.nginx.com/nginx/admin-guide/)
- [NGINX Technical Specs](https://docs.nginx.com/nginx/technical-specs/)
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [NGINX Architecture Blog](https://www.nginx.com/blog/inside-nginx-how-we-designed-for-performance-scale/)

<br/>

### Authors

- Chris Akker - Solutions Architect - Community and Alliances @ F5, Inc.
- Shouvik Dutta - Solutions Architect - Community and Alliances @ F5, Inc.
- Kevin Jones - Technical Evanglist - Community and Alliances @ F5, Inc.

-------------

Navigate to ([Lab2](../lab2/readme.md) | [Main Menu](../readme.md))
