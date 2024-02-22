# NGINX Reverse Proxy and HTTP Load Balancing

## Introduction

In this lab, you will build a test lab environment using NGINX and Docker.  This will require that you build and run NGINX Opensource as a `Reverse Proxy Load Balancer` in a Docker container.  Then you will run three NGINX demo web servers, to be used as your `backend` web servers.  After all the containers are running, you will test and verify each container, the NGINX Proxy and the web servers.  All of these NGINX containers will be used as a learning platform to complete the remaining Lab Exercises.  It is important to build and run these NGINX containers correctly to complete the exercises and receive the most benefit from the Workshop.

NGINX OSS | Docker
:-------------------------:|:-------------------------:
![NGINX OSS](media/nginx-icon.png)  |![Docker](media/docker-icon.png)
  
## Learning Objectives

By the end of the lab you will be able to:

- Build and run an `NGINX Opensource Docker` image
- Build your Workshop enviroment with Docker Compose
- Verify Container build with NGINX tests
- Configure NGINX Extended Access Logging
- Configure NGINX for Load Balancing
- Add NGINX features following Best Practices

## Pre-Requisites

- You must have Docker installed and running
- You must have Docker-compose installed
- See `Lab0` for instructions on setting up your system for this Workshop
- Familiarity with basic Linux commands and commandline tools
- Familiarity with basic Docker concepts and commands
- Familiarity with basic HTTP protocol

## Build the Workshop Environment with Docker Compose

For this lab you will build/run 4 Docker containers.  The first one will be used as an NGINX-OSS reverse proxy, and other 3 will be used for upstream backend web servers.

![Lab4 diagram](media/lab4_lab-diagram.png) 

### Configure the NGINX-OSS Docker build parameters

1. Inspect the Dockerfile, located in the `/lab4/nginx-oss folder`.  Notice the `FROM` build parameter uses the `NGINX Alpine mainline` image, and also the `RUN apk add` command, which installs additional tool libraries in the image.  These tools are needed for copy/edit of files, and to run various tests while using the container in the exercises.  NOTE: you can choose a different NGINX base image if you like, but these lab exercises are written to use the Alpine image.

    ```bash
    FROM nginx:mainline-alpine
    RUN apk add --no-cache curl ca-certificates bash bash-completion jq wget vim

    ```

1. Inspect the `docker-compose.yml` file, located in the /lab4 folder.  Notice you are building and running the NGINX-OSS web and Proxy container, (using the modified `/nginx-oss/Dockerfile` from the previous step).  

    ```bash
    ...
    nginx-oss:                  # NGINX OSS Web / Load Balancer
        hostname: nginx-oss
        build: nginx-oss          # Build new container, using /nginx-oss/Dockerfile
        volumes:                  # Sync these folders to container
            - ./nginx-oss/etc/nginx/nginx.conf:/etc/nginx/nginx.conf
            - ./nginx-oss/etc/nginx/conf.d:/etc/nginx/conf.d
            - ./nginx-oss/etc/nginx/includes:/etc/nginx/includes
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
    ##Sample output##
    CONTAINER ID   IMAGE                   COMMAND                  CREATED       STATUS       PORTS                                                              NAMES
    6ede3846edc3   lab4-nginx-oss          "/docker-entrypoint.…"   3 hours ago   Up 3 hours   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:9000->9000/tcp   nginx-oss
    e4887e475a14   nginxinc/ingress-demo   "/docker-entrypoint.…"   3 hours ago   Up 3 hours   0.0.0.0:56086->80/tcp, 0.0.0.0:56087->443/tcp                      web1
    a0a5b33bcf68   nginxinc/ingress-demo   "/docker-entrypoint.…"   3 hours ago   Up 3 hours   443/tcp, 0.0.0.0:56084->80/tcp, 0.0.0.0:56085->433/tcp             web2
    51dec7d94c6f   nginxinc/ingress-demo   "/docker-entrypoint.…"   3 hours ago   Up 3 hours   0.0.0.0:56082->80/tcp, 0.0.0.0:56081->443/tcp                      web3

    ```

1. Verify `all` of your three web backend servers are working.  Using a Terminal, Docker exec into each one, and verify you get a response to a curl request.  The `Name` should be `web1`, `web2`, and `web3` respectively for each container.

    ```bash
    docker exec -it web1 bin/sh   # log into web1 container, then web2, then web3

    ```

    ```bash
    curl -s http://localhost |grep Name

    ```

    ```bash
    ##Sample outputs##

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
    ##Sample outputs##
   <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    
    ...snip

    <p><em>Thank you for using nginx.</em></p>
    </body>
    </html>

    ```

    Congrats - you should see the `Welcome to nginx!` page.

<br/>

### NGINX Status Page

<br/>

NGINX also includes a status page, which shows some basic metrics about the traffic going through NGINX, such as:
    - Active Connections
    - Connections Accepted, Handled
    - Total number of Requests
    - Reading, writing, and waiting counters.

These are helpful when looking at if/how NGINX is handling traffic.

1. Inspect the `stub_status.conf` file located in the `/etc/nginx/conf.d` folder.  You will see that it is listening on port 9000, and using the URL of `/basic_status`.  This has been provided for you to monitor your traffic, there is a link in the References section with more information on the `stub_status module`.

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

1. Give that a try, test access to the NGINX `stub_status` page, on port 9000:

    ```bash
    curl http://localhost:9000/basic_status

    ```

    ```bash
    ##Sample output##
    Active connections: 1
    server accepts handled requests
    56 56 136
    Reading: 0 Writing: 1 Waiting: 0

    ```

1. Try it in a browser at <http://localhost:9000/basic_status>. It should looks similar to this:

    ![NGINX Status](media/lab4_nginx-status.png)

<br/>

### NGINX Reverse Proxy

<br/>

Now that you know all 4 containers are working with the NGINX Welcome page, and the basic_status page, you can build and test the **NGINX OSS Proxy and Load Balancing** functions.  You will use a new `NGINX proxy_pass Directive` - you will start with Reverse Proxy configuration, test it out.  Then add the Upstream backends and test out Load Balancing.

- Using your previous lab exercise experience, you will configure a new NGINX configuration for the `cafe.example.com` website.  It will be very similar to `cars.example.com.conf` from lab3.  

- This will require a new NGINX config file, for the Server and Location Blocks.

1. In the /`etc/nginx/conf.d folder`, create a new file named `cafe.example.com.conf`, which will be the config file for the Server and Location blocks for this new website.  

    However, instead of a Location block that points to a folder with html content on disk, you will tell NGINX to `proxy_pass` the request to one of your three web containers instead.  

    >This will show you how to unlock the amazing power of NGINX...
    >>it can serve it's own content,
    >>> or **content from another web server!**

    Docker Exec into your nginx-oss container.

    ```bash
    docker exec -it nginx-oss bin/bash   # log into nginx-oss container
    ```

    ```bash
    cd /etc/nginx/conf.d
    vi cafe.example.com.conf
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

        location / {
            
        ### New NGINX Directive, "proxy_pass", tells NGINX to proxy traffic to another server.
            
            proxy_pass http://web1;        # Send requests to web1
        }

    } 
    
    ```

    Save the file and Quit VI.  Test and Reload your NGINX config.

2. Test if your Proxy_pass configuration is working, using curl several times, and your browser.

    ```bash
    curl -s http://cafe.example.com |grep Server

    ```

    ```bash
    ##Sample output##

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

    >This is called a `Direct proxy_pass`, where you are telling NGINX to Proxy the request to another server.  You can also use a FQDN name, or an IP:port with proxy_pass.  In this lab environment, Docker is providing the IP for web1.

3. You can even use proxy_pass in front of a public website.  Try that, with `nginx.org`...what do you think, can you use a Docker container on your desktop to deliver someone else's website?  No, that `can't` be that easy, can it ?

    ```bash
    docker exec -it nginx-oss bin/sh   # log into nginx-oss container

    ```

    ```bash
    cd /etc/nginx/conf.d
    vi cafe.example.com.conf

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
            
        # New NGINX Directive, "proxy_pass", tells NGINX to proxy traffic to another website.
            
            proxy_pass http://nginx.org;    # Send all requests to nginx.org website 
        }

    } 
    
    ```

    Save the file and Quit VI.  Test and Reload your NGINX config.

4. Try it with Chrome, http://cafe.example.com.  Yes, that works alright, NGINX sends your cafe.example.com request to `nginx.org`.  No WAY, that's cool.

    ![Proxy_pass NGINX.org](media/lab4_proxypass-nginx-org.png)

<br/>

### NGINX Load Balancing

You see the `proxy_pass` working for one backend webserver, but what about the other 2 backends?  Do you need high availability, and increased capacity for your website? Of course, you want to use multiple backends for this, and load balance them.  This is very easy, as it requires only 2 configuration changes:

- Create a new .conf file for the Upstream Block
- Modify the proxy_pass to use the name of this upstream block

You will now configure the `NGINX Upstream Block`, which is a `list of backend servers` that can be used by NGINX Proxy for load balancing requests.

1. Using Terminal, Docker Exec into the nginx-oss container.  Change to the `/etc/nginx/conf.d` folder, where HTTP config files are kept. Create a new file named `upstreams.conf`, which will be the config file for the Upstream Block with three backends - web1, web2, and web3.

    ```bash
    docker exec -it nginx-oss bin/sh   # log into nginx-oss container

    ```

    ```bash
    cd /etc/nginx/conf.d
    vi upstreams.conf

    ```

    Place the three backend containers in an "upstream block" as shown:

    ```nginx
    # NGINX Basics, OSS Proxy to three upstream NGINX containers
    # Chris Akker, Shouvik Dutta - Feb 2024
    #
    # nginx_cafe servers

    upstream nginx_cafe {         # Upstream block, the name is "nginx_cafe"

        # Load Balancing Algorithms supported by NGINX
        # - Round Robin (Default if nothing specified)
        # - Least Connections
        # - IP Hash
        # - Hash (Any generic Hash)     

        # Uncomment for Least Connections algorithm      
        # least_conn;

        # From Docker-Compose:
        server web1:80;
        server web2:80;
        server web3:80;

        #Uncomment for IP Hash persistence
        # ip_hash;

        # Uncomment for keepalive TCP connections to upstreams
        # keepalive 16;

    }

    ```

    Save the file and Quit VI.

1. Modify the `proxy_pass` directive in `cafe.example.com.conf`, to proxy the requests to the `upstream block called nginx_cafe`.  And it goes without saying, you can have literally hundreds of upstream blocks for various backend apps, but each upstream block name must be unique.  (And you can have hundreds of backends, if you need that much capacity for your website).

    ```bash
    cd /etc/nginx/conf.d
    vi cafe.example.com.conf

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
            
        ### Change the "proxy_pass" directive, tell NGINX to proxy traffic to the upstream block.  
        ### If there is more than one server, they will be load balanced
            
            proxy_pass http://nginx_cafe;        # Must match the upstream block name
        }

    } 
    
    ```

    Save the file and Quit VI. Test and Reload your NGINX config.

1. Verify that it is load balancing to `all three containers`, run the curl command at least 3 times:

    ```bash
    docker exec -it nginx-oss bin/sh   # log into nginx-oss container

    ```

    ```bash
    curl -is http://cafe.example.com |grep Server     # run at least 3 times

    ```

    ```bash
    ##Sample output##

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

>This is called an `Upstream proxy_pass`, where you are telling NGINX to Proxy the request to a list of servers in the upstream, and load balance them.

1. These backend application do have the following multiple paths which can also be used for testing. Feel free to try them out:
   - [http://cafe.example.com/coffee](http://cafe.example.com/coffee)
   - [http://cafe.example.com/tea](http://cafe.example.com/tea)
   - [http://cafe.example.com/icetea](http://cafe.example.com/icetea)
   - [http://cafe.example.com/beer](http://cafe.example.com/beer)
   - [http://cafe.example.com/wine](http://cafe.example.com/wine)
   - [http://cafe.example.com/cosmo](http://cafe.example.com/cosmo)
   - [http://cafe.example.com/mojito](http://cafe.example.com/mojito)
   - [http://cafe.example.com/daiquiri](http://cafe.example.com/daiquiri)

<br/>

### NGINX Extended Access Logging

Now that you have a working NGINX Proxy, and several backends, you will be adding and using additional NGINX Directives, Variables, and testing them out.  In order to better see the results of these new Directives on your proxied traffic, you need better and more information in your Access logs.  The default NGINX `main` access log_format only contains a fraction of the information you need, so you will  `extend` it to include much more information, especially about the Upstream backend servers.

1. In this next exercise, you will use a new `log_format` which has additional $variables added the access.log, so you can see this metadata.  You will use the Best Practice of defining the log format ONCE, but potentially use it in many Server blocks.

1. Inspect the `main` access log_format that is the default when you install NGINX.  You will find it in the `/etc/nginx/nginx.conf` file.  As you can see, there is `nothing` in this log format about the Upstreams, Headers, or other details you need.

    ```nginx
    ...snip from /etc/nginx/nginx.conf

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

                    # nothing above on Upstreams, how do you even know which server handled the request ???

    ...

    ```

1. Inspect the `main_ext.conf` configuration file, located in the `/etc/nginx/includes/log_formats` folder.  You will see there are many added $variables, some are for the request, some for proxy functions, some for the response, and several are about the Upstream (so you know which backend was chosen and used for a request).  NGINX has `hundreds` of $variables you can use, depending on what you need to see.

    ```nginx
    # Extended Log Format
    # Nginx Basics
    log_format  main_ext    'remote_addr="$remote_addr", '
                            '[time_local=$time_local], '
                            'request="$request", '
                            'status="$status", '
                            'http_referer="$http_referer", '
                            'body_bytes_sent="$body_bytes_sent", '
                            'Host="$host", '
                            'sn="$server_name", '
                            'request_time=$request_time, '
                            'http_user_agent="$http_user_agent", '
                            'http_x_forwarded_for="$http_x_forwarded_for", '
                            'request_length="$request_length", '
                            'upstream_address="$upstream_addr", '
                            'upstream_status="$upstream_status", '
                            'upstream_connect_time="$upstream_connect_time", '
                            'upstream_header_time="$upstream_header_time", '
                            'upstream_response_time="$upstream_response_time", '
                            'upstream_response_length="$upstream_response_length", ';
                            
    ```

1. You will use the Extended log_format for the next few exercises.  Update your `cafe.example.com.conf` to use the `main_ext` log format:

    ```nginx
    # cars.example.com HTTP
    # NGINX Basics Workshop
    # Feb 2024, Chris Akker, Shouvik Dutta
    #
    server {
        
        listen 80;      # Listening on port 80 on all IP addresses on this machine

        server_name cafe.example.com;   # Set hostname to match in request

        access_log  /var/log/nginx/cafe.example.com.log main_ext;         # Change this to "main_ext"
        error_log   /var/log/nginx/cafe.example.com_error.log notice;

    ...snip

    ```

    Save your file.  Test and Reload NGINX.

1. Test your new log format.  Docker Exec into your nginx-oss container.  Tail the /var/log/nginx/cafe.example.com.log Access log file, and you will see the new Extended Log Format.

    ```bash
    tail -f /var/log/nginx/cafe.example.com.log

    ```

1. Watch your new log format.  Using curl or your browser, hit the `cafe.example.com` website a few times.

    It should look something like this (comments and line breaks added for clarity):

    ```bash
    ##Sample output##

    # Raw Output
    remote_addr="192.168.65.1", [time_local=19/Feb/2024:19:14:32 +0000], request="GET / HTTP/1.1", status="200", http_referer="-", body_bytes_sent="651", Host="cafe.example.com", sn="cafe.example.com", request_time=0.001, http_user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36", http_x_forwarded_for="-", request_length="471",
    upstream_address="172.18.0.3:80",  # Nice, now you know what backend was selected
    upstream_status="200", 
    upstream_connect_time="0.000", 
    upstream_header_time="0.000", 
    upstream_response_time="0.000", 
    upstream_response_length="651",

    # Line Breaks added  

    ```

    As you can see here, NGINX has `many $variables` that you can use, to customize the Access log_format to meet your needs.  You will find a link to NGINX Access Logging, and ALL the NGINX Variables that are availabe in the References section below.

    It should also be pointed out, that you can use different log formats for different Hosts, Server Blocks, or even different Location Blocks, you are not limited to just one log_format.

<br/>

### NGINX Proxy Protocol and Keep-alives

<br/>

Now that you have Reverse Proxy and load balancing working, you need to think about what information should be passed to and from the backend servers.  After all, if you insert a Proxy in between the client and the server, you might lose some important information in the request or the response.  `NGINX proxy_headers` are used to restore this information, and add additional information as well using NGINX $variables.  Proxy headers are also used to control the HTTP protocol itself, which you will do first.

In this next exercise, you will define these HTTP Protocol Headers, and then tell NGINX to use them in your `cafe.example.com` Server block, so that every request and response will now include these new headers.  

**NOTE:** When NGINX proxies a request to an Upstream, it uses the HTTP/1.0 protocol by default, for legacy compatibility.  

However, this means a new TCP connection for every request, and is quite inefficient.  Modern apps mostly run HTTP/1.1, so you will tell NGINX to use HTTP/1.1 for Proxied requests, which allows NGINX to re-use TCP connections for multiple requests.  (This is commonly called HTTP keepalives, or HTTP pipelining).

1. Inspect the `keepalive.conf`, located in the /etc/nginx/includes folder.  Notice that there are three Directives and Headers required for HTTP/1.1 to work correctly:

    - HTTP Protocol = Use the `$proxy_protocol_version` variable to set it to `1.1`.
    - HTTP Connection Header = should be blank, `""`, the default is `Close`.
    - HTTP Host = the HTTP/1.1 protocol requires a Host Header be set, `$host`

    ```nginx
    #Nginx Basics - Feb 2024
    #Chris Akker, Shouvik Dutta
    #
    # Default is HTTP/1.0 to upstreams, HTTP keepalives needed for HTTP/1.1
    proxy_http_version 1.1;

    # Set the Connection header to empty 
    proxy_set_header Connection "";

    # Host request header field, or the server name matching a request
    proxy_set_header Host $host;

    ```

1. Using Terminal, Docker Exec into your nginx-oss Proxy, and edit your `cafe.example.com.conf` to use the HTTP/1.1 protocol to the Upstreams with an `include`:

    ```bash
    docker exec -it nginx-oss bin/sh   # log into nginx-oss container

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
            
            # Uncomment to enable proxy headers, and keepalives
            # include includes/proxy_headers.conf;

            include includes/keepalive.conf;     # Use HTTP/1.1 keepalives
            
            # proxy_pass http://web1;            # Proxy to another server
            proxy_pass http://nginx_cafe;        # Proxy AND load balance to a list of servers
        }

    } 
    ```

1. Using curl, send a request to your website, and look at the Headers sent back:

    ```bash
    curl -I http://cafe.example.com

    ```

    ```bash
    ##Sample output##
    HTTP/1.1 200 OK                          # protocol version is 1.1
    Server: nginx/1.25.4
    Date: Sat, 17 Feb 2024 01:41:01 GMT
    Content-Type: text/html; charset=utf-8
    Connection: keep-alive                   # Connection header = keep-alive
    Expires: Sat, 17 Feb 2024 01:41:00 GMT
    Cache-Control: no-cache

    ```

1. Using your browser, open its "Dev Tools", or "Inspect" option, so you can see the browser's debugging metadata.  Visit your website, <http://cafe.example.com>.  If you click on the Network Tab, and then the first object, you will see the Request and Response Headers, and should find that `Connection:` = `keep-alive`

    ![Chrome keep-alive](media/lab4_chrome-keepalive.png)

<br/>

### NGINX Custom Request Headers

<br/>

Now you need to enable some HTTP Headers, to be added to the Request.  These are often need to relay information between the HTTP client and the backend server. These Headers are in addition to the HTTP Protocol control headers.

1. Inspect the `proxy_headers.conf` in the `/etc/nginx/includes` folder.  You will see that some custom HTTP Headers are being added.

    ```nginx
    #Nginx Basics - Feb 2024
    #Chris Akker, Shouvik Dutta
    #
    ## Set Headers to the proxied servers ##

    # client address in binary format
    proxy_set_header X-Real-IP $remote_addr;

    # X-Forwarded-For client request header 
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    # request scheme, “http” or “https”
    proxy_set_header X-Forwarded-Proto $scheme;

    ```

1. Using Terminal, Docker Exec into your nginx-oss Proxy, and edit your `cafe.example.com.conf` to use the `proxy_headers.conf` with an `include`:

    ```bash
    docker exec -it nginx-oss bin/sh   # log into nginx-oss container

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
            
            # Uncomment to enable custom headers, and keepalives

            include includes/proxy_headers.conf; # Add Request Headers

            include includes/keepalive.conf;     # Use HTTP/1.1 and keep-alives
            
            # proxy_pass http://web1;            # Proxy to another server
            proxy_pass http://nginx_cafe;        # Proxy AND load balance to a list of servers
        }

    } 
    ```

<br/>

### NGINX Load Balancing Algorithms and Load Testing

Different backend applications may benefit from using different load balancing techniques.  NGINX support both legacy and more modern algorithms for different use cases.  You will configure and test several of these algorithms, put them under a Loadtest, and observe the results.  Then you will add/change some Directives to improve performance, and Loadtest again and see if it made any difference.

1. NGINX's default Load Balancing algorithm is round-robin.  In this next lab exercise, you will use the `least connections` algorithm to send more traffic to different backends based on their active TCP connection counts.  You will modify your `upstreams.conf` file to enable Least Connections, as follows:

    ```nginx

    ...snip

        # Uncomment for Least Connections algorithm
        least_conn;
        
        # Docker-compose:
        server web1:80;
        server web2:80;
        server web3:80;

    ```

    Save your file.  Test and Reload your NGINX config.

1. If you open the NGINX Basic Status page at <http://localhost:9000/basic_status>, and refresh it every 3-4 seconds while you run the `WRK HTTP loadtest` at your nginx-oss Load Balancer:  

    Loadtesting with WRK.  This is a docker container that will download and run, with 4 threads, at 200 connections, for 2 minutes:

    ```bash
    docker run --name wrk --network=lab4_default --rm williamyeh/wrk -t4 -c200 -d2m -H 'Host: cafe.example.com' --timeout 2s http://nginx-oss/coffee

    ```

    In the `basic_status` page, you should notice about 200 Active Connections, and the number of `server requests` should be increasing rapidly.  Unfortunately, there is no easy way to monitor the number of TCP connections to Upstreams when using NGINX Opensource.  But good news, you `will` see all the Upstream metrics in the next lab with NGINX Plus!

    After the 5 minute WRK loadtest has finished, you should see a Summary of the statistics.  It should look similar to this:

    ```bash
    ##Sample output##
    Running 2m test @ http://nginx-oss/coffee
    4 threads and 200 connections
    Thread Stats   Avg      Stdev     Max   +/- Stdev
        Latency    51.99ms   25.29ms   1.60s    99.19%
        Req/Sec     0.98k    86.96     2.95k    86.86%
    1170593 requests in 5.00m, 1.82GB read
    Requests/sec:   3900.71                            # Good performance ?
    Transfer/sec:      6.21MB

    ```

    Well, that performance looks pretty good, about 3900 HTTP Reqs/second.  But NGINX can do better.  You will enable TCP keepalives to the Upstreams.  This Directive will tell NGINX to create a `pool of TCP connections to each Upstream`, and use that established connection pool to rapid-fire HTTP requests to the backends.  `No delays waiting for the TCP handshakes!`  It is considered a Best Practice to enable keepalives to the Upstream servers.

1. Edit the `upstreams.conf` file, and remove the Comment from the `# keepalives 16` line.

    ```nginx
    upstream nginx_cafe {

        # Load Balancing Algorithms supported by NGINX
        # - Round Robin (Default if nothing specified)
        # - Least Connections
        # - IP Hash
        # - Hash (Any generic Hash)     

        
        # Uncomment for Least Connections algorithm
        least_conn;

        # Docker-compose:
        server web1:80;
        server web2:80;
        server web3:80;
                            
        # Uncomment for IP Hash persistence
        # ip_hash;

        # Uncomment for keepalive TCP connections to upstreams
        keepalive 16;

    }

    ```

    Save your file.  Test and Reload your NGINX config.

    Run the WRK test again.  You should now have `least_conn` and `keepalive` both **enabled**.

    After the 2 minute WRK test has finished, you should see a Summary of the statistics.  It should look similar to this:

    ```bash
    ##Sample output##
    Running 2m test @ http://nginx-oss/coffee
    4 threads and 200 connections
    Thread Stats   Avg      Stdev     Max   +/- Stdev
        Latency    25.48ms   16.93ms 825.44ms   98.58%
        Req/Sec     2.02k   281.30     3.98k    79.17%
    2417366 requests in 5.00m, 3.76GB read
    Requests/sec:   8056.82                             # NICE, much better!
    Transfer/sec:     12.82MB

    ```

    >>Wow, more that **DOUBLE the performance**, with Upstream `keepalive` enabled - over 8,000 HTTP Reqs/second.  Did you see a performance increase??  Your mileage here will vary of course, depending on what kind of machine you are using for these Docker containers.

    >Note:  In the next Lab, you will use NGINX Plus, which `does` have detailed Upstream metrics, which you will see in real-time while loadtests are being run. 
   
1. In this next lab exercise, you will use the `weighted` algorithm to send more traffic to different backends.  You will modify the `server`entries in youor `upstreams.conf` file to set an administrative ratio, as follows:

    ```nginx
    ...snip

        # Docker-compose:
        # Add weights to all three servers

        server web1:80 weight=1;   
        server web2:80 weight=3;
        server web3:80 weight=6;

    ```

    Save your file.  Test and Reload your NGINX config.

1. Test again with curl and your browser, you should see a response distribution similar to the server weights. 10% to web1, 30% to web2, and 60% to web3.

1. For a fun test, hit it again with WRK...what do you observe?  Do admin weights help or hurt performance?  

    ![Docker Dashboard](media/lab4_docker-perf-weighted.png)
    
    Only the results will tell you for sure, checking the Docker Desktop Dashboard - looks like the CPU ratio on the web containers matches the `weight` values for the Upstreams.

    So that is not too bad for a single CPU docker container.  But didn't you hear that NGINX performance improves with the number of CPUs in the machine?

1. Check your `nginx.conf` file... does it say `worker_processes   1;` near the top?  Hmmm, NGINX is configured to use only one Worker and therefore only one CPU core.  You will change it to `FOUR`, and re-test.  Assuming you have at least 4 cores that Docker and NGINX can use:

    ```nginx
    user  nginx;
    worker_processes  4;      # Change to 4 and re-test

    error_log  /var/log/nginx/error.log warn;
    pid        /var/run/nginx.pid;


    events {
        worker_connections  1024;
    }

    ...snip

    ```

    Save your file.  
    
    NOTE:  The NGINX default setting for `worker_processes` is `auto`, which means one Worker for every CPU core in the machine.  However, some Virtualization platforms, and Docker will often set this value to 1, something to be aware of and check.

1. Edit the `upstreams.conf` file, remove the `server weight=x` parameter from all three servers, and set the load balancing algorithm back to `least_conn`.  

    Save your file. Test and Reload your NGINX config.

1. You should now have `4 workers`, `least_conn` and `keepalive` **enabled**.  Run the WRK test again. You are going to CRANK IT UP!

    Docker Exec into the nginx-oss container, and run `top` to see the NGINX Workers at work.  Should look something like this:

    ```bash
    ##Sample output##
    Mem: 4273520K used, 3863844K free, 5364K shrd, 30348K buff, 3166924K cached
    CPU:  18% usr  35% sys   0% nic  11% idle   0% io   0% irq  33% sirq
    Load average: 13.75 4.73 3.71 17/703 63
    PID  PPID USER     STAT   VSZ %VSZ CPU %CPU COMMAND
    61     1 nginx    R     9964   0%  10   7% nginx: worker process
    59     1 nginx    R     9988   0%   9   7% nginx: worker process
    60     1 nginx    R     9972   0%   3   7% nginx: worker process
    62     1 nginx    R     9920   0%   1   7% nginx: worker process
    1     0 root     S     9036   0%   4   0% nginx: master process nginx -g daemon off;
    30     0 root     S     1672   0%  10   0% /bin/sh
    63    30 root     R     1600   0%   3   0% top

    ```
    
    After the 2 minute WRK test has finished, you should see a Summary of the statistics.  It should look similar to this:

    ```bash
    ##Sample output##
    Running 2m test @ http://nginx-oss/coffee
    4 threads and 200 connections
    Thread Stats   Avg      Stdev     Max   +/- Stdev
        Latency     9.33ms    3.60ms 134.99ms   78.81%
        Req/Sec     5.40k   721.76    10.97k    74.55%
    6452981 requests in 5.00m, 10.03GB read
    Socket errors: connect 0, read 0, write 0, timeout 13
    Requests/sec:  21503.04                                 # Even better w/ 4 cores 
    Transfer/sec:     34.23MB

    ```

    Over 21,000 Requests/Second from a little Docker container...not too shabby!  

    Was your Docker Desktop was humming along, with the fan on full blast?!

    ![Docker Dashboard](media/lab4_docker-perf-4core.png)
    
    Summary:  NGINX can and will use whatever hardware resources you provide.  And as you can see, you were shown just a few settings, but there are **MANY** NGINX configuration parameters that affect performance.  Only time, experience, and rigorous testing will determine which NGINX Directives and values will work best for Load Balancing your application.

<br/>

### NGINX Persistence / Affinity

<br/>

With many legacy applications, the HTTP client and server must create a temporal unique relationship for the duration of the transaction or communication session.  However, when proxies or load balancers are inserted in the middle of the communication, it is important to retain this affinity between the client and the server. The Load Balancer industry commonly refers to this concept as `Persistence`, or `Sticky`, or `Affinity`, depending on which term the vendor has chosen to use.

With NGINX, there are several configuration options for this, but in this next lab exercise, you will use the most common option called `ip hash`.  This will allow NGINX to send requests to the same backend based on the client's IP Address.

1. Docker exec into your nginx-oss container, and in the `/etc/nginx/conf.d` folder, edit the `upstreams.conf` file as follows:

    ```nginx
    # NGINX Basics, OSS Proxy to three upstream NGINX web servers
    # Chris Akker, Shouvik Dutta - Feb 2024
    #
    # nginx-cafe servers 
    upstream nginx_cafe {

        # Load Balancing Algorithms supported by NGINX
        # - Round Robin (Default if nothing specified)
        # - Least Connections
        # - IP Hash
        # - Hash (Any generic Hash)     
        
        # Uncomment for Least Connections algorithm
        # least_conn;

        # Docker-compose:
        server web1:80;
        server web2:80;
        server web3:80;

        #Uncomment for IP Hash persistence
        ip_hash;

        # Include keep alive connections to upstreams
        keepalive 16;

    }

    ```

    Save your file. Test and Reload your NGINX config.

1. Test out `ip_hash` persistence with curl and your browser.  You should find that now NGINX will always send your request to the same backend, it will no longer round-robin or least-conn load balance your requests to all three backends.

    ```bash
    curl -s http://cafe.example.com |grep IP    # try 5 or 6 times

    ```

1. Try the WRK loadtest again, with the IP Hash enabled, you can only use ONE backend server:

    Looks like web3 is the chosen one:

    ![Docker Dashboard](media/lab4_docker-perf-iphash.png)

    After testing, you might considering adding `least_conn` and removing `ip_hash` for future exercises.

<br/>

If you need to find the `answers` to the lab exercises, you will find the final NGINX configuration files for all the labs in the /lab4/final folder.  Use them for reference to compare how you completed the labs.

>**Congratulations, you are now a member of Team NGINX !**

![NGINX Logo](media/nginx-logo.png)

**This completes Lab4.**

<br/>

## References:

- [NGINX OSS](https://nginx.org/en/docs/)
- [NGINX Status Module](http://nginx.org/en/docs/http/ngx_http_stub_status_module.html)
- [NGINX Admin Guide](https://docs.nginx.com/nginx/admin-guide/)
- [NGINX Technical Specs](https://docs.nginx.com/nginx/technical-specs/)
- [NGINX Variables](https://nginx.org/en/docs/varindex.html)
- [NGINX Access Logging](https://nginx.org/en/docs/http/ngx_http_log_module.html#access_log)
- [NGINX Load Balancing Methods](https://docs.nginx.com/nginx/admin-guide/load-balancer/http-load-balancer/#method)
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [WRK Docker image](https://registry.hub.docker.com/r/williamyeh/wrk)

<br/>

### Authors
- Chris Akker - Solutions Architect - Community and Alliances @ F5, Inc.
- Shouvik Dutta - Solutions Architect - Community and Alliances @ F5, Inc.

-------------

Navigate to ([Lab5](../lab5/readme.md) | [Main Menu](../readme.md))
