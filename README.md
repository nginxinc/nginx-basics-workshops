![NGINX Basics Workshop Banner](media/basics-workshop-banner.png)

<br/>

# Under Construction - This workshop is under a re-write.  Use at your own risk.

<br/>

# NGINX Basics Workshop

## Welcome!

<br/>

> ><strong>Welcome to the NGINX OSS and Plus Basics Workshop!</strong>

<br/>

This Workshop will introduce `NGINX Webserver and Reverse Proxy` with hands-on practice through self-paced lab exercises.

You will learn about `NGINX` Opensource Software (OSS) and `NGINX Plus`, the Commerical version of NGINX, with no prior experience required.  The lab exercises provided will teach you by example how to install, configure, test, operate, troubleshoot, and fix NGINX; using common commands, tools, and applications.  There are dozens of use cases for NGINX, this Basics Workshop will focus on the most common ones for new users and deployments.  This Workshop content is designed to run in almost any environment that can host Docker and Linux containers, for broad appeal and consumption by users. 

You will learn how to configure NGINX Webserver, deploy it with Docker, configure basic and some advanced NGINX features, loadtest it, and monitor it in realtime. You will deploy new apps and services, terminate SSL, route HTTP traffic, configure redirects, set up healthchecks, and load balance traffic to running servers.  You will add some Security features, follow Best Practices, and become proficient with basic NGINX configurations.  These Hands-On Lab Exercises are designed to be independent, with later labs adding additional services and features as you progress through them. Completing the labs in sequential order is highly recommended. 

By the end of this Workshop, you will have a working, operational NGINX OSS or Plus Docker environment, routing traffic to and from backend web application servers, with the necessary skills to deploy and operate NGINX for your own Modern Applications. Thank You for taking the time to attend this NGINXpert Workshop!

<br/>

![NGINXpert Desk](media/nginx-workshop-desk.png)

<br/>

## Goals 

 * Overview of NGINX History and Architecture
 * How to build and setup NGINX OSS and NGINX Plus on Docker
 * How to configure NGINX for basic web server functions
 * How to configure NGINX for Proxy functions
 * How to monitor, log, troubleshoot, and fix common issues
 * Provide examples of NGINX configurations best practices
 * Provide an overview of NGINX Plus
 * Introduction to third party integrations like Prometheus and Grafana
 * Introduction to more Advanced Topics

## Prerequisites

To successfully complete the Hands On exercises for this Workshop, there are both knowledge and technical requirements.

### Knowledge Requirements

- You should be familiar with the Linux command line, copying, editing, and saving files.
- You should be familiar with TCP, HTTP, SSL, and basic networking concepts.
- You should be familiar with basic Docker and container commands and concepts.
- You should be familiar with Computer Desktop apps like Chrome, Visual Studio Code, Postman, Terminal.
- Optional, you should be familiar with load balancing concepts and terminology.

### Technical Requirements

The Hands On lab exercises are written for users with a host running multiple Docker containers.  These containers are quite small, and should all run easily on most modern computer hardware.  You will need to provide the following components, prior to starting the exercises:

1. A Docker host, with [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) installed and running.

2. Admin access to your local computer to install and run various software packages.  See the `lab0 folder` for details on setting up your computer for this Workshop.

3. Admin access to your local /etc/hosts file.  The lab uses the FQDN hostnames: `www.example.com` and `www2.example.com`. For hostname resolution you will need to add these hostnames to your local DNS hosts file.

   For example, on Linux/macOS the host file is located at `/etc/hosts`:

   ```bash
   # NGINX Plus Basics lab hostnames (local docker hosts)
   127.0.0.1 example.com www.example.com www2.example.com nginx-plus-1 web1 web2 web3

   ```

> **Note on Docker DNS:**
>
> DNS resolution between containers is provided by default using the bridged network by docker networking, and NGINX has been pre-configured to use the Docker internal DNS server (127.0.0.11) to provide DNS resolution between the containers.  Your Docker environment may be different.

4. An NGINX Plus subscription or Trial license will be required to complete the NGINX PLUS lab exercises. You can request a free 30-day Trial from [NGINX Plus Trial](https://www.nginx.com/free-trial-request/).  An email with download links to the license files will normally arrive within a few hours of submitting a request.

### How to use the Lab Guides

To ensure understanding of every step, every line which is to be entered by the user is preceded by `$>`. This is intentional so the user must type and enter each line, instead of bulk copy/paste. It is highly recommended that you type ALL the commands yourself, to facilitate better understanding and retention of this content.  (Insert Mavin typing memory retention study results here).

## The Workshop environment

1. This Workshop is built to only require the user's computer, no servers or VMs are needed.

1. The user's computer, which will host all the Docker containers, and provide a Desktop UI for using various apps, like Chrome, Visual Studio Code, Postman, Terminal.

1. `See Lab0, for details on installing the required software for your platform.`  You will likely need full administrative privleges to properly install and configure the software.

1. As you progress thru the lab exercises, you will be adding more containers, and more features and options to NGINX.  **It is important that you complete the lab exercises in the order presented in this Workshop, so that you can see and learn how to configure NGINX properly, and complete all exercises successfully.**

1. The docker containers used are as follows:
- NGINX Opensource ADC/load balancer, named `nginx-oss,`
- NGINX Plus ADC/load balancer, named `nginx-plus,`
- Web servers #1, 2, and 3; named `web1`, `web2` and `web3` respectively.

1. List and details of the containers:

  * **NGINX OSS** `(Latest)` based on Alpine Linux. 
  * **NGINX Plus** `(Latest)` based on Debian Linux. 
  * **NGINX Web#** `(Latest)` is based on
   [**nginxinc/ingress-demo**](https://hub.docker.com/r/nginxinc/ingress-demo).
   NGINX web servers that serve simple HTML pages containing the Hostname, IP address
   and port, request URI, local time, request id, and other metadata.
 * **Lab Guide** can be read with a web browser starting at [LabGuide](https://github.com/nginxinc/nginx-basics-workshop/LabGuide.md).

>NOTE:  All the container images are built on your computer, so they will be available `after` the Workshop, so you can use them for further learning, testing and as reference material. All the documentation and sample config files, including the Lab Guides, will also be available on NGINX's `GitHub` repo.  As you make changes to your config files, you will need to make copies or back them up yourself.

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

<br/>

**This completes the Introduction.**

<br/>

## References:

- [NGINX Plus](https://docs.nginx.com/nginx/)
- [NGINX Admin Guide](https://docs.nginx.com/nginx/admin-guide/)
- [NGINX Technical Specs](https://docs.nginx.com/nginx/technical-specs/)
- [NGINX Resources](ttps://www.nginx.com/resources/)
- [NGINX Blogs](https://www.nginx.com/blog/)
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

<br/>

### Authors
- Chris Akker - Solutions Architect - Community and Alliances @ F5, Inc.
- Shouvik Dutta - Solutions Architect - Community and Alliances @ F5, Inc.

-------------

Click the lab1/readme.md to get started ([LabX](../labX/readme.md) | [Main Menu](../LabGuide.md))
