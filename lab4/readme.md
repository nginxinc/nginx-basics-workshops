# NGINX Reverse Proxy and Load Balancing

## Introduction

In this lab, you will build a test lab environment using NGINX and Docker.  This will require that you build and run NGINX Opensource as a `Reverse Proxy Load Balancer` in a Docker container.  Then you will run three NGINX demo web servers, to be used as your `backend` web servers.  After all the containers are running, you will test and verify each container, the NGINX Proxy and the web servers.  All of these NGINX containers will be used as a learning platform to complete the remaining Lab Exercises.  It is important to build and run these NGINX containers correctly to complete the exercises and receive the most benefit from the Workshop.

NGINX OSS | Docker
:-------------------------:|:-------------------------:
![NGINX OSS](media/nginx-icon.png)  |![Docker](media/docker-icon.png)
  
## Learning Objectives 

By the end of the lab you will be able to: 
 * Build an `NGINX Opensource Docker` image
 * Build your Workshop enviroment with Docker Compose
 * Run the NGINX OSS image
 * Verify initial container build and NGINX tests
 * Create NGINX configuration for Load Balancing
 * Add additonal NGINX parameters following Best Practices

## Pre-Requisites

- You must have Docker installed and running
- You must have Docker-compose installed
- See `Lab0` for instructions on setting up your system for this Workshop
- Familiarity with basic Linux commands and commandline tools
- Familiarity with basic Docker concepts and commands
- Familiarity with basic HTTP and HTTPS protocol

## Build the Workshop Environment with Docker Compose

For this lab you will build/run 4 Docker containers.  The first one will be used as an NGINX-OSS reverse proxy, and other 3 will be used for upstream backend web servers.

< diagram needed here >

### Configure the NGINX-OSS Docker build parameters

1. Inspect the Dockerfile, located in the `/lab4/nginx-oss folder`.  Notice the `FROM` build parameter uses the `NGINX Alpine mainline` image, and also the `RUN apk add` command, which installs additional tool libraries in the image.  These tools are needed for copy/edit of files, and to run various tests while using the container in the exercises.  NOTE: you can choose a different NGINX base image if you like, but these lab exercises are written to use the Alpine image.

    ```bash
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

    ```

1. Inspect the `docker-compose.yml` file, located in the /lab4 folder.  Notice you are building and running the NGINX-OSS web and Proxy container, (using the modified `/nginx-oss/Dockerfile` from the previous step).  

    ```bash
    ...
    nginx-oss:                  # NGINX OSS Web / Load Balancer
        hostname: nginx-oss
        build: nginx-oss          # Build new container, using /nginx-oss/Dockerfile
        links:
            - web1:web1
            - web2:web2
            - web3:web3
        ports:
            - 80:80       # Open for HTTP
            - 443:443     # Open for HTTPS
            - 9000:9000   # Open for stub status page
        restart: always 

    ```

    Also notice in the `docker-compose.yml` you are running three Docker NGINX webserver containers, using an image from Docker Hub.  These will be your upstreams, backend webservers for the exercises.

    ```bash
    ...
    web1:
        hostname: web1
        image: nginxinc/ingress-demo       # Image from Docker Hub
        ports:
            - "80"                           # Open for HTTP
            - "443"                          # Open for HTTPS
    web2:
        hostname: web2
        image: nginxinc/ingress-demo
        ports:
            - "80"
            - "433"
    web3:
        hostname: web3
        image: nginxinc/ingress-demo
        ports:
            - "80"
            - "443"   

    ```

1. Verify all four containers are running:

    ```bash
    docker ps -a

    ```

    ```bash
    #Sample output
    CONTAINER ID   IMAGE                   COMMAND                  CREATED       STATUS       PORTS                                                              NAMES
    6ede3846edc3   lab4-nginx-oss          "/docker-entrypoint.…"   3 hours ago   Up 3 hours   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:9000->9000/tcp   nginx-oss
    e4887e475a14   nginxinc/ingress-demo   "/docker-entrypoint.…"   3 hours ago   Up 3 hours   0.0.0.0:56086->80/tcp, 0.0.0.0:56087->443/tcp                      web1
    a0a5b33bcf68   nginxinc/ingress-demo   "/docker-entrypoint.…"   3 hours ago   Up 3 hours   443/tcp, 0.0.0.0:56084->80/tcp, 0.0.0.0:56085->433/tcp             web2
    51dec7d94c6f   nginxinc/ingress-demo   "/docker-entrypoint.…"   3 hours ago   Up 3 hours   0.0.0.0:56082->80/tcp, 0.0.0.0:56081->443/tcp                      web3

    ```

1. Verify `each` of your three web backend servers are working.  Using a Terminal, Docker exec into each one, and verify you get a response to a curl request.  The `Name` should be `web1`, `web2`, and `web3` respectively for each container.

    ```bash
    docker exec -it web1 bin/sh   # log into web1 container

    ```
   
    ```bash
    curl -s http://localhost |grep Name

    ```

    ```bash
    #Sample outputs

    <p class="smaller"><span>Server Name:</span> <span>web1</span></p>   # web1

    <p class="smaller"><span>Server Name:</span> <span>web2</span></p>   # web2

    <p class="smaller"><span>Server Name:</span> <span>web3</span></p>   # web3

    ```
    Check all three, just to be sure.  Exit the Docker Exec when you are finished.

1. Test the NGINX OSS container, verify it also sends back a response to a curl request:

    ```bash
    docker exec -it nginx-oss bin/sh   # log into nginx-oss container

    ```
   
    ```bash
    curl http://localhost

    ```

    ```bash
    #Sample outputs
   <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style>
    html { color-scheme: light dark; }
    body { width: 35em; margin: 0 auto;
    font-family: Tahoma, Verdana, Arial, sans-serif; }
    </style>
    </head>
    <body>
    <h1>Welcome to nginx!</h1>
    <p>If you see this page, the nginx web server is successfully installed and
    working. Further configuration is required.</p>

    <p>For online documentation and support please refer to
    <a href="http://nginx.org/">nginx.org</a>.<br/>
    Commercial support is available at
    <a href="http://nginx.com/">nginx.com</a>.</p>

    <p><em>Thank you for using nginx.</em></p>
    </body>
    </html>

    ```
    Congrats - you should see the `Welcome to nginx!` page.

1. NGINX also includes a status page, which shows some basic metrics about the traffic going through NGINX, such as:
    - Active Connections
    - Connections Accepted, Handled
    - Total number of Requests
    - Reading, writing, and waiting counters.
 
    These are helpful when looking at if/how NGINX is handling traffic.
    
    Inspect the `stub_status.conf` file located in the `/etc/nginx/conf.d` folder.  You will see that it is listening on port 9000, and using the URL of `/basic_status`.  This has been provided for you to monitor your traffic, there is a link in the References section with more information on the `stub_status module`.

    ```nginx
    # ngx_http_stub_status_module (available in NGINX OSS)
    # provides Basic Status information

    server {
        listen 9000;              # Listener for Stub Status
        
        location /basic_status {
            stub_status;
        }

        # Redirect requests for "/" to "/basic_status"
    location / {
        return 301 /basic_status;
        }

    }

    ```

    Give that a try, test access to the NGINX `stub_status` page, on port 9000: 

    ```bash
    curl http://localhost:9000/basic_status

    ```

    ```bash
    #Sample output
    Active connections: 1
    server accepts handled requests
    56 56 136
    Reading: 0 Writing: 1 Waiting: 0

    ```

    Try it in a browser at http://localhost:9000/basic_status 

    It should looks similar to this:
    
    ![NGINX Status](media/lab4_nginx-status.png)

1. Now that you know all 4 containers are working with the NGINX Welcome page, and the stub_status page, you can build and test the **NGINX OSS Proxy and Load Balancing** functions.

    - Using your previous lab exercise experience, you will configure a new NGINX configuration for the `cafe.example.com` website.  It will be very similar to `cars.example.com` from lab3.  
    
    - This will require a new NGINX config file, for the Server and Location Blocks.
    
1. In the /`etc/nginx/conf.d folder`, create a new file named `cafe.example.com.conf`, which will be the config file for the Server and Location blocks for this new website.  

    However, instead of a Location block that points to a folder with html files on disk, you will tell NGINX to proxy the request to one of your web containers instead.  

    >This will show you how to unlock the power of NGINX...`it can serve it's own content, or content from another web server!`

    ```bash
    docker exec -it nginx-oss bin/sh   # log into nginx-oss container

    ```

    ```bash
    $ cd /etc/nginx/conf.d
    $ vi cafe.example.com.conf

    ```

    ```nginx
    # cafe.example.com HTTP
    # NGINX Basics Workshop
    # Feb 2024, Chris Akker, Shouvik Dutta
    #
    server {
        
        listen 80;      # Listening on port 80 on all IP addresses on this machine

        server_name cafe.example.com;   # Set hostname to match in request

        access_log  /var/log/nginx/cafe.example.com.log main; 
        error_log   /var/log/nginx/cafe.example.com_error.log notice;

        root /usr/share/nginx/html;         # Set the root folder for the HTML and JPG files

        location / {
            
        # New NGINX Directive, "proxy_pass", tells NGINX to proxy traffic to another server.
            
            proxy_pass http://web1;        
        }

    } 
    
    ```
    
    Save the file.

    Test and Reload your NGINX config.

1.  Test if your Proxy configuration is working, using curl several times, and your browser.

    ```bash
    curl -s http://cafe.example.com |grep Server

    ```

    ```bash
    #Sample output

      Server: nginx/1.25.4
      <p class="smaller"><span>Server Name:</span> <span>web1</span></p>   # web1
      <p class="smaller"><span>Server Address:</span> <span><font color="green">172.28.0.4:80</font></span></p>

      Server: nginx/1.25.4
      <p class="smaller"><span>Server Name:</span> <span>web1</span></p>   # web1
      <p class="smaller"><span>Server Address:</span> <span><font color="green">172.28.0.4:80</font></span></p>

      Server: nginx/1.25.4
      <p class="smaller"><span>Server Name:</span> <span>web1</span></p>   # web1
      <p class="smaller"><span>Server Address:</span> <span><font color="green">172.28.0.4:80</font></span></p>

    ```

    Likewise, your browser refreshes should show you the "Out of stock" graphic and webpage for web1.  If you like, change the `proxy_pass` to `web2` or `web3`, and see what happens.

    >This is called a `Direct proxy_pass`, where you are telling NGINX to Proxy the request to another server.  You can also use a FQDN name, or an IP:port with proxy_pass.

<br/>

### NGINX Load Balancing

You see the Proxy_pass working for one backend webserver, but what about the other 2?  Do you need high availability, and increased capacity for your website? Of course, you want to use multiple backends for this, and load balance them.  

You will now configure the `NGINX Upstream Block`, which is a `list of backend servers` that can be used by NGINX Proxy for load balancing requests.

1. Using Terminal, Docker Exec into the nginx-oss container.  Change to the `/etc/nginx/conf.d` folder, where http config files are kept. Create a new file named `upstreams.conf`, which will be the config file for the three backends, web1, 2, and 3.

    ```bash
    docker exec -it nginx-oss bin/sh   # log into nginx-oss container

    ```

    ```bash
    $ cd /etc/nginx/conf.d
    $ vi upstreams.conf

    ```

    Place the three backend containers in an "upstream block" as shown:

    ```nginx
    # NGINX Basics, OSS Proxy to three upstream NGINX containers
    # Chris Akker, Shouvik Dutta - Feb 2024
    #
    # nginx_cafe servers

    upstream nginx_cafe {         # Upstream block, the name is "nginx_cafe"

        server web1:80;           # These are the containers from your Docker Compose
        server web2:80;
        server web3:80;

    }

    ```
    Save the file.

1. Modify the `proxy_pass` directive in cafe.example.com.conf, to proxy the requests to the `upstream block called nginx_cafe`.

    ```bash
    $ cd /etc/nginx/conf.d
    $ vi cafe.example.com.conf

    ```

    ```nginx
    # cafe.example.com HTTP
    # NGINX Basics Workshop
    # Feb 2024, Chris Akker, Shouvik Dutta
    #
    server {
        
        listen 80;      # Listening on port 80 on all IP addresses on this machine

        server_name cafe.example.com;   # Set hostname to match in request

        access_log  /var/log/nginx/cafe.example.com.log main; 
        error_log   /var/log/nginx/cafe.example.com_error.log notice;

        root /usr/share/nginx/html;         # Set the root folder for the HTML and JPG files

        location / {
            
        # Change the "proxy_pass" directive, tell NGINX to proxy traffic to the upstream block.  If there is more than one server, they will be load balanced
            
            proxy_pass http://nginx_cafe;        # Must match the upstream block name
        }

    } 
    
    ```

    Save the file. Test and Reload your NGINX config.

1. Verify that it is load balancing to `all three containers`, run this command at least 3 times:

    ```bash
    docker exec -it nginx-oss bin/sh   # log into nginx-oss container

    ```
    
    ```bash
    curl -is http://cafe.example.com |grep Server

    ```

    ```bash
    #Sample output

      Server: nginx/1.25.4
      <p class="smaller"><span>Server Name:</span> <span>web1</span></p>   # web1
      <p class="smaller"><span>Server Address:</span> <span><font color="green">172.28.0.4:80</font></span></p>

      Server: nginx/1.25.4
      <p class="smaller"><span>Server Name:</span> <span>web2</span></p>   # web2
      <p class="smaller"><span>Server Address:</span> <span><font color="green">172.28.0.3:80</font></span></p>

      Server: nginx/1.25.4
      <p class="smaller"><span>Server Name:</span> <span>web3</span></p>   # web3
      <p class="smaller"><span>Server Address:</span> <span><font color="green">172.28.0.2:80</font></span></p>

    ```

    You should see `Server Names` like `web1`, `web2`, and `web3` as NGINX load balances all three backends - your NGINX-OSS is now a Reverse Proxy, and load balancing traffic to 3 web containers! Notice the `Server Address`, with the IP address of each upstream container.  Note:  Your IP addresses will likely be different.

1. Test again, this time using a browser, click `Refresh` at least 3 times:

    Using your browser, go to http://cafe.example.com

    You should see the `Out of Stock` web page, note the `Server Name` and `Server Addresses`.

    NGINX Web1 | NGINX Web2 | NGINX Web3 
    :-------------------------:|:-------------------------:|:-------------------------:
    ![NGINX Web1](media/lab4_nginx-web1.png)  |![NGINX Web2](media/lab4_nginx-web2.png) |![NGINX Web3](media/lab4_nginx-web3.png)

>This is called an `Upstream proxy_pass`, where you are telling NGINX to Proxy the request to a list of servers in the upstream, and load balance them.  You can also use a FQDN name, or an IP:port with proxy_pass.

<br/>
   
1. NGINX Headers


1. NGINX Persistence / Affinity


<br/>

>**Congratulations, you are now a member of Team NGINX !**

![NGINX Logo](media/nginx-logo.png)

**This completes this Lab.**

<br/>

## References:

- [NGINX OSS](https://nginx.org/en/docs/)
- [NGINX Status Module](http://nginx.org/en/docs/http/ngx_http_stub_status_module.html)
- [NGINX Admin Guide](https://docs.nginx.com/nginx/admin-guide/)
- [NGINX Technical Specs](https://docs.nginx.com/nginx/technical-specs/)
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

<br/>

### Authors
- Chris Akker - Solutions Architect - Community and Alliances @ F5, Inc.
- Shouvik Dutta - Solutions Architect - Community and Alliances @ F5, Inc.

-------------

Navigate to ([Lab5](../lab5/readme.md) | [Main Menu](../LabGuide.md))
