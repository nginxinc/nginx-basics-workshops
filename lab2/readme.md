# Introduction to NGINX web server

## Introduction

In this lab, NGINX as a web server will be introduced.  NGINX architecture and basic operations, as well as basic web and content serving principles will be covered.

## Learning Objectives 

By the end of the lab you will be able to: 
 * Describe NGINX origins, architecture, and operations
 * Create and edit NGINX configs following best practices
 * Create NGINX configurations for basic web content
 
 * Be proficient with NGINX logging files, formats, variables

## The History of NGINX

NGINX was originally written in 2002 by Igor Sysov while he was working at rambler.ru, a web company providing Internet Search content.  As Rambler continued to grow, Igor kept hitting the practical limit of 10,000 simultaneous HTTP requests with Apache.  The only way to handle more traffic was to build and run more servers.  So NGINX was written as the answer to the `C10k concurrency problem` - how do you handle more than 10,000 concurrent requests on a single Linux server.  Igor created a new TCP connection handling concept call the `Worker`.  The worker is a process that continually waits for incoming TCP connections, and immediately handles the Request, and delivers the Response.  It is event-driven programming logic.  Importantly, NGINX workers can use any CPU, and can scale up in performance as the hardware scales up, providing a nearly linear performance curve.  There are many articles written and available about this NGINX Worker connection architecture if you are interested in reading more about it. 

Another architecural concept in NGINX worth noting, is the `NGINX Master` process.  The master process interacts with the Linux OS, controls the Workers, reads config files, writes to error and logging files, validates configuration changes, then loads them into memory.  It is considered the Control plane process, while the Workers are considered the Data plane processes.  The separation of Control functions from Data handling functions is also very beneficial to handling high volumes of web traffic.

NGINX also uses a Shared memory model, where common elements are equally accessed by all workers.  This reduces the overall memory footprint considerably, making NGINX very lightweight, and ideal for containers and other small compute environments.  You can literally run NGINX off a legacy floppy disk !

In the NGINX Architectural diagram below, you can see these different core components of NGINX, and how they relate to each other.  You will notice that Control and Management type functions are separate and independent from the Data flow functions of the Workers that are handling the traffic.  You will find links to NGINX core architectures and concepts in the References section.

>> It is this unique architecture that makes NGINX so powerful and efficient.

![NGINX Architecture](media/lab2_nginx-architecture.png)

In 2004, NGINX was released as open source software (OSS).  It rapidly gained popularity and has been adopted by millions of websites since.

In 2013, NGINX Plus as released, providing additional features and Commercial Support for Enterprise customers. 


## NGINX Commands

```bash

#displays NGINX version detauls
$ nginx -v

#graceful shutdown
$ nginx -s quit

#terminates all NGINX processes
$ nginx -s stop

#configuration syntax test
$ nginx -t

#reloads configurations
$ nginx -s reload

#dumps the current running configurations
$ nginx -T

```



### NGINX Reloads

What does NGINX do, when you change the configuration and request a reload?  At a high level, this is what NGINX does:

- The `nginx -s reload` command sends a SIGHUP signal to the Linux Kernel.
- The master process reads all the config files, and validates the syntax, configuration commands, variables, and many other dependencies.  It also validates that any dependent Linux system level objects are correct, like folder/file names and paths, file permissions, networking objects like IP addresses, sockets, etc.  If there are any errors, it prints out the configuration filename and the line number where the error exists, and some helpful information, like "path /cahce not found" (you have a typo: /cahce should be spelled /cache).  The validation STOPS on the first error encountered.  So you must address the error, and run `nginx -t` again to further check for errors.
- Once the master process configuration validation is successful, then NGINX will do the following:
1. with NGINX OSS, the Worker processes are immediately shutdown, along with all existing TCP connections.  The master process then spawns new Worker processes, and they begin handling traffic based on the new configuration.  Any traffic in flight is dropped.
2. with NGINX Plus, new Worker processes are created, and begin using the new configuration immediately for all new connections and requests.  The old Workers are allowed to complete their job, and close their TCP connections naturally, traffic in flight is not dropped!  The master process terminates the old Workers after they close all their connections.  This is called Dynamic Reconfiguration in NGINX Plus documentation.
- The nginx master process writes log information about the reload to the error.log so you can see what happened when.

< NGINX start, stop, error.log lab exercises here - systemctl, top, ps aux, etc >


### NGINX Configuration - Contexts, Includes, Directives, Blocks

- Contexts
- Includes
- Directives
- Blocks

`Contexts` refer to which SECTION of the NGINX configuration you are working with.

`Includes` refer to additional files that NGINX should use for configuration.

`Directives` refer to NGINX configurations consisting of 2 types:

- Simple directives - these are single line commands with some parameters that end in a semi-colon;

- Block directives - these are multiple line commands, with an opening and closing curly brace **`{}`**.   A block directive will contain single line directives, and also can contain other block directives, called nested blocks.

Let's take a look at some examples, using the default `nginx.conf` that comes installed with NGINX.

Inspect the nginx.conf file, here are some explanations:

```bash
# This is the "main" NGINX context, where NGINX gets its start up parameters
# Notice main does NOT have curly braces {} !
#

user  nginx;                               #Linux user
worker_processes  auto;                    #Number of Workers

error_log  /var/log/nginx/error.log warn;  #set NGINX error log path and name and level
pid        /var/run/nginx.pid;             #set NGINX master process PID file

```

```bash
# This is the block and context called "events"
# Configures NGINX Workers and other core parameters
#

events {                                   
    worker_connections  1024;              #each Worker should handle 1024 connections
}

```

```bash
# This is the "http" context, used for all http configurations
# Notice the "includes", which tells NGINX to use these files
#

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # Set the access log format
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    # Set the path and name and format for the access log
    access_log  /var/log/nginx/access.log  main;

    sendfile        on;

    keepalive_timeout  65;

    # Use all .conf files located in the in /etc/nginx/conf.d folder
    include /etc/nginx/conf.d/*.conf;  

}

```

```bash
# This is a "server" and "location" block, used for creating the http virtual server
# And creating the URL paths 
#
# NOTICE:  the location blocks are nested within the server block
#

server {
    listen       80;                  # TCP port to listen on
    server_name  localhost;           # HTTP hostname matching

    access_log  /var/log/nginx/host.access.log  main;    # Notice the custom filename

    location / {                         # URL to look for "/", the base
        root   /usr/share/nginx/html;    # folder for content to be served
        index  index.html index.htm;     # default html page to use
    }

    location /images/ {                   # URL to look for "/images" 
        root   /data;                     # folder for images
    }
)

```

![NGINX Contexts](media/lab2_nginx-contexts.png)


In general, the contexts and blocks are in a logical hierarchy that follows the construction of an HTTP URL, as follows.

main and events > nginx start up parameters
http > high level http parameters - logging, data types, timers, include files
server > virtual server parameters - port, hostname, access log, include files
location > URL path, object type

http://www.example.com:8080/images/smile.png

schema://hostname:port/path/file.type



### NGINX Linux File Structure

The hierarchy of these contexts also maps to how the folders/files are laid out on disk. This is how the folders and files are laid out for these lab exercises, following NGINX guidelines and best practices.

```
< /etc/nginx tee here >

```


## NGINX static web content

Now that you have a basic understanding of the NGINX binary, contexts, and configuration files, let's look at how NGINX operates as a web server.  You will configure some HTML pages, and create NGINX configs to serve some content based on the URL in the HTTP request.


**This completes this Lab.**

<br/>

## References:

- [NGINX Beginner's Guide](https://nginx.org/en/docs/beginners_guide.html)
- [NGINX OSS](https://nginx.org/en/docs/)
- [NGINX Admin Guide](https://docs.nginx.com/nginx/admin-guide/)
- [NGINX on Floppy disk](https://www.youtube.com/watch?v=IjjiTD-1Cvg)


<br/>

### Authors
- Chris Akker - Solutions Architect - Community and Alliances @ F5, Inc.
- Shouvik Dutta - Solutions Architect - Community and Alliances @ F5, Inc.

-------------

Navigate to ([Lab3](../lab3/readme.md) | [Main Menu](../LabGuide.md))
