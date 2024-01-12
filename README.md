![NGINX Basics Workshop Banner](media/nicworkshop-banner.png)

< Change Banner >

# Under Construction - This workshop is under a re-write.  Use at your own risk.

<br/>

# NGINX Basics Workshop

## Welcome!

<br/>

> ><strong>Welcome to the NGINX Plus Basics Workshop!</strong>

<br/>

This Workshop will introduce `NGINX web and proxy servers` with hands-on practice through self-paced lab exercises.  You will learn about NGINX and NGINX Plus, with no prior experience required.  These lab exercises will teach you by example how to install, configure, test, operate, troubleshoot, and fix NGINX; using common commands, tools, and applications.  There are literally dozens of use cases for NGINX, this Basics Workshop will focus on the most common ones for new users and deployments.  This Workshop content is designed to run in almost any environment that can run Docker and Linux containers, for broad appeal and consumption by users. 

These Hands-On Lab Exercises are designed to build upon each other, adding additional functions and features as you progress through them, completing the labs in sequential order is required.

<br/>

![Developer Seated](media/developer-seated.svg)

<br/>

## Goals 

 * Provide an introduction to NGINX Plus
 * How to install and setup NGINX Plus on Virtual Machines and Docker
 * How to configure NGINX for web server functions
 * How to configure NGINX for Proxy functions
 * How to monitor, log, troubleshoot, and fix common issues
 * Provide examples of NGINX configurations best practices
 * Introduction to more Advanced Topics

## Prerequisites

To successfully complete the Hands On exercises for this Workshop, there are both knowledge and technical requirements.

### Knowledge Requirements

- You should be familiar with the Linux command line, copying, editing, and saving files.
- You should be familiar with TCP, HTTP, SSL, and basic networking concepts.
- You should be familiar with basic Docker and container concepts.
- Optional, you should be familiar with load balancing concepts and terminology.

### Technical Requirements

The Hands On lab exercises are written for hosts running as Docker containers.  These containers are quite small, and should all run easily on most modern laptops or servers.  You will need to provide the following components, prior to starting the exercises:

1. NGINX Plus subscription or Evaluation license files. You can request a free 30-day Trial from [NGINX Plus Trial](https://www.nginx.com/free-trial-request/).  The license files will normally arrive in your email within a few hours of submitting a request.

2. A Docker host, with [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) installed and running.

3. Admin access to your local /etc/hosts file.  The lab uses the FQDN hostnames: `www.example.com` and `www2.example.com`. For hostname resolution you will need to add these hostnames to your local DNS hosts file.

   For example, on Linux/Unix/macOS the host file is located at `/etc/hosts`:

   ```bash
   # NGINX Plus Basics lab hostnames (local docker hosts)
   127.0.0.1 example.com www.example.com www2.example.com nginx-plus-1 web1 web2 web3
   ```

> **Note on Docker DNS:**
>
> DNS resolution between containers is provided by default using the bridged network by docker networking, and NGINX has been pre-configured to use the Docker internal DNS server (127.0.0.11) to provide DNS resolution between the containers.  Your Docker environment may be different.

### How to use this document

To ensure understanding of every step, every line which is to be entered by the user is preceded by `$>`. This is intentional so the user must type and enter each line, instead of bulk copy/paste. It is highly recommended that you type ALL the commands yourself, to facilitate better understanding and retention of this content.  (Insert Harvard typing memory retention study results here.)

## The Workshop environment

This Workshop is built with 2 components.

1. An Ubuntu Desktop, which will host all the Docker containers, and provide a Linux Desktop UI for using various appls, like Chrome, VisualStudio Code, Postman, Terminal.
1. An Ubuntu Virtual Machine, which is used to show the installation of NGINX Plus on a Virtual Machine.

As you progress thru the lab exercises, you will be adding more containers, and more features and options to NGINX.  `It is important that you complete the lab exercises in the order presented in this Workshop, so that you can see and learn how to configure NGINX properly, and complete all exercises successfully.`

The docker containers used are as follows:
- NGINX Plus ADC/load balancer, named `nginx-plus,`
- Web server #1, 2, and 3; named `web1`, `web2` and `web3` respectively.

List and details of the containers:

 * **NGINX Plus** `(Latest)` based on ubuntu 22.04. An example centos7 Dockerfile is provided for information only.
 * **NGINX OSS** `(Latest)` is based on
   [**nginx-hello**](https://github.com/nginxinc/NGINX-Demos/tree/master/nginx-hello).
   NGINX web servers that serve simple HTML pages containing the Hostname, IP address
   and port as wells as the request URI, the local time of the webserver, and other metadata.
 * **Lab Guide** can be read from the [`docs/labs` folder](docs/labs/README.md)
   or in a web browser on [LabGuide](https://github.com/nginxinc/nginx-basics-workshop/LabGuide.md).

**Note:**[NGINX Plus Documentation](https://docs.nginx.com/nginx/),
[resources](https://www.nginx.com/resources/) and
[blog](https://www.nginx.com/blog/) are your best source of information for
addtional technical information. There are many detailed examples found on the
internet too!

>NOTE:  All the containers will be available `after` the lab, so you can use them for further testing and as reference material. All the documentation and sample config files, including the Lab Guides, are self-hosted on the Ubuntu Desktop, and will also be available on NGINX's `GitHub` repo.

### Topology

This is the workshop Docker Compose environment for the lab exercises:

< Need Diagram here >

```
                                             (nginx-hello upstream: 
                                             nginx1:80, nginx2:80, nginx3:80)
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
HTTP/Port 9000        |               |       |        *        |
                      |               |       |                 |
                      |               |       +-----------------+
                      +---------------+                                                                                    

                                              +-----------------+         
                                              |                 |
                                              |      docs       |
+-------------------------------------------->|   (lab guide)   |
LAB GUIDE                                     |                 |
HTTP/PORT 90                                  |                 |
                                              +-----------------+

```

## File Structure

This is how the folders and files are laid out for these lab exercises, following NGINX guidelines and best practices.

```
/
├── etc/
│    ├── nginx/
│    │    ├── conf.d/ # ADD your HTTP/S configurations here
│    │    │   ├── example.com.conf............HTTP www.example.com Virtual Server configuration
│    │    │   ├── www2.example.com.conf.......HTTPS www2.example.com Virtual Server configuration
│    │    │   ├── upstreams.conf..............Upstream configurations
│    │    │   ├── stub_status.conf............NGINX Open Source basic status information available http://localhost/nginx_status only
│    │    │   └── status_api.conf.............NGINX Plus Live Activity Monitoring available on port 9000 - [Source](https://gist.github.com/nginx-gists/│a51 341a11ff1cf4e94ac359b67f1c4ae)
│    │    ├── includes
│    │    │    ├── add_headers/ # Headers to attach to client response
│    │    │    │   └── security.conf_ ........Recommended response headers for security
│    │    │    ├── error_pages/ # Custom Error Pages
│    │    │    │   ├── error_pages.conf.......NGINX configurations for custom error pages
│    │    │    │   ├── http403.conf_ .........Example HTTP 403 custom error pages
│    │    │    │   └── http404.conf_ .........Example HTTP 404 custom error pages
│    │    │    ├── log_formats/ # Custom extended log formats
│    │    │    │   ├── ext_log_formats.conf...Example custom log formats
│    │    │    │   └── json_log_formats.conf..Example JSON custom log formats
│    │    │    ├── proxy_cache/ # Proxy cache configurations
│    │    │    │   └── image_cache.conf_ .....Example proxy cache configurations for static web content e.g. Images
│    │    │    ├── proxy_headers/ # Headers to attach to upstream request
│    │    │    │   ├── keepalive.conf.........Recommended HTTP keepalives headers for performance
│    │    │    │   └── proxy_headers.conf.....Recommended request headers for request routing and logging
│    │    │    └── ssl # TLS Configurations examples
│    │    │        ├── ssl_intermediate.conf..Recommended SSL configuration for General-purpose servers with a variety of clients, recommended for almost all systems
│    │    │        ├── ssl_a+_strong.conf.....Recommended SSL configuration for Based on SSL Labs A+ (https://www.ssllabs.com/ssltest/)
│    │    │        ├── ssl_modern.conf........Recommended SSL configuration for Modern clients: TLS 1.3 and don't need backward compatibility
│    │    │        └── ssl_old.conf...........SSL configuration for compatiblity ith a number of very old clients, and should be used only as a last resort
│    │    ├── stream.conf.d/ # TODO: ADD your TCP and UDP Stream configurations here
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



## Build and run the Workshop environment

Provided the Prerequisites have been met before running the steps below, this is
a **working** environment.

### Build the Lab containers

As outlined above, you will have a one NGINX Plus ADC/load balancer (`nginx-plus`) and
three NGINX OSS webservers (`web1`, `web2` and `web3`)

Before you start the build, you need to copy your NGINX Plus repo key and certificate files
(`nginx-repo.key` and `nginx-repo.crt`) into the proper directory,  `nginx-plus/etc/ssl/nginx/`.  Docker will use these files to download the appropriate NGINX Plus files, then build your stack:

```bash
# Enter working directory
$> cd nginx-basics

# Make sure your Nginx Plus repo key and certificate exist here
$> ls nginx-plus/etc/ssl/nginx/nginx-*
nginx-repo.crt              nginx-repo.key

# Downloaded docker images and build
$> docker-compose pull
$> docker-compose build --no-cache
```

-----------------------
> See other other useful [`docker`](docs/useful-docker-commands.md) and
> [`docker-compose`](docs/useful-docker-compose-commands.md) commands
-----------------------------------------------------------------------

#### Start the Demo stack:

Run `docker-compose` in the foreground so we can see real-time log output to the
terminal:

```bash
$> docker-compose up
```

Or, if you made changes to any of the Docker containers or NGINX configurations, run:

```bash
# Recreate containers and start demo
$> docker-compose up --force-recreate
```

**Confirm** all the containers are running. You should see three containers running:

```bash
$> docker ps
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS              PORTS                                                              NAMES
791ccac223ac        nginx-basics_nginx-plus   "nginx -g 'daemon of…"   5 seconds ago       Up 4 seconds        0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:8080->8080/tcp   nginx-basics_nginx-plus_1
eacbc5630b4b        nginx-basics_docs         "/docker-entrypoint.…"   6 seconds ago       Up 5 seconds        80/tcp, 0.0.0.0:9000->9000/tcp                                     nginx-basics_docs_1
9ae4b20dd15e        nginx-basics_web1         "/docker-entrypoint.…"   6 seconds ago       Up 5 seconds        80/tcp, 90/tcp                                                     nginx-basics_web1_1
8de6c4e7b672        nginx-basics_web2         "/docker-entrypoint.…"   6 seconds ago       Up 5 seconds        0.0.0.0:1119->80/tcp, 0.0.0.0:1118->90/tcp                         nginx-basics_web2_1
0a31be1a3f13        nginx-basics_web3         "/docker-entrypoint.…"   6 seconds ago       Up 5 seconds        0.0.0.0:1121->80/tcp, 0.0.0.0:1120->90/tcp                         nginx-basics_web3_1
```

The demo environment is ready in seconds. You can access the `nginx-hello` demo
website on **HTTP / Port 80** ([`http://localhost`](http://localhost) or
[http://www.example.com](http://example.com)) and on **HTTPS / Port 443**
([https://www2.example.com](http://example.com)).

The NGINX API is available on **HTTP / Port 8080**
([`http://localhost:8080`](http://localhost)) or
[http://www.example.com:8080](http://example.com:8080))

The lab guide is available on [http://localhost:9000](http://localhost:9000). 

#### Upload to UDF

This demo system can also be ported to UDF

1. Get the UDF Address (URL and Port) for the target NGINX Plus Load Balancer
   Instance

![UDF ssh info](docs/labs/intro/media/2020-06-25_15-29.png)

2. `scp` the NGINX Plus Load Balancer configurations: 

```bash
# Enter working directory
$> cd nginx-basics
# Set variables
USER=ubuntu
HOST=bb56acb6-d774-4bed-b783-005a491b274b.access.udf.f5.com
PORT=47000
DATE_WITH_TIME=`date "+%Y%m%d-%H%M%S"`
# Push local nginx plus config to remote server while making backup first
$> ssh -p $PORT $USER@$HOST "sudo cp -r /etc/nginx /var/tmp/nginx-$DATE_WITH_TIME"
$> ssh -p $PORT $USER@$HOST "sudo rm -rf /var/tmp/nginx-new"
$> scp -r -P $PORT nginx-plus/etc/nginx $USER@$HOST:/var/tmp/nginx-new 
$> ssh -p $PORT $USER@$HOST "sudo rsync -Prtv --exclude modules/ --delete /var/tmp/nginx-new/* /etc/nginx"
$> ssh -p $PORT $USER@$HOST "sudo chown -R nginx:nginx /etc/nginx"
```

3. Get the UDF Address (URL and Port) for the target Web Server NGINX Instance

![UDF ssh info](docs/labs/intro/media/2020-06-26_11-53.png)

4. `scp` the NGINX web server configuration: 

```bash
# Set variables
$> USER=ubuntu
$> HOST=bb56acb6-d774-4bed-b783-005a491b274b.access.udf.f5.com
$> PORT=47001
$> DATE_WITH_TIME=`date "+%Y%m%d-%H%M%S"`
# Push local nginx web server config to remote server while making backup first
$> ssh -p $PORT $USER@$HOST "sudo cp -r /etc/nginx /var/tmp/nginx-$DATE_WITH_TIME"
$> ssh -p $PORT $USER@$HOST "sudo rm -rf /var/tmp/nginx-new"
$> scp -r -P $PORT nginx-hello/etc/nginx $USER@$HOST:/var/tmp/nginx-new 
# Copy Lab guide config
$> scp -r -P $PORT docs/misc/lab_guide.conf $USER@$HOST:/var/tmp/nginx-new/conf.d 
$> ssh -p $PORT $USER@$HOST "sudo rsync -Prtv --exclude modules/ --delete /var/tmp/nginx-new/* /etc/nginx"
$> ssh -p $PORT $USER@$HOST "sudo chown -R nginx:nginx /etc/nginx"
# Push local web to remote server while making backup first
$> ssh -p $PORT $USER@$HOST "sudo cp -r /usr/share/nginx/html /var/tmp/nginx-html-$DATE_WITH_TIME"
$> ssh -p $PORT $USER@$HOST "sudo rm -rf /var/tmp/nginx-new-html"
$> scp -r -P $PORT nginx-hello/usr/share/nginx/html $USER@$HOST:/var/tmp/nginx-new-html 
# Copy Lab guide
$> scp -r -P $PORT docs/labs $USER@$HOST:/var/tmp/nginx-new-html 
$> ssh -p $PORT $USER@$HOST "sudo rsync -Prtv --delete /var/tmp/nginx-new-html/* /usr/share/nginx/html"
# Sync to other Web servers (if you have others configured with nginx-sync.sh)
# Note: If there is a incorrect host in /root/.ssh/known_hosts, you may need to 
# run the nginx-sync.sh command on the server, not remotely:
$> ssh -p $PORT $USER@$HOST "sudo nginx-sync.sh"
```

Example `nginx-sync.conf` on the web server:

```bash
# nginx-sync.conf
NODES="web2 web3"
CONFPATHS="/etc/nginx /etc/ssl /usr/share/nginx/html"
#EXCLUDE="default.conf"
```

**This completes this Lab.**

<br/>

## References:

- [NGINX Plus](https://docs.nginx.com/nginx/)
- [NGINX Admin Guide](https://docs.nginx.com/nginx/admin-guide/)
- [NGINX Technical Specs](https://docs.nginx.com/nginx/technical-specs/)
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

<br/>

### Authors
- Chris Akker - Solutions Architect - Community and Alliances @ F5, Inc.
- Shouvik Dutta - Solutions Architect - Community and Alliances @ F5, Inc.

-------------

Navigate to ([LabX](../labX/readme.md) | [Main Menu](../LabGuide.md))
