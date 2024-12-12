# Using the Nginx One Console

## Introduction

In this lab, you will be exploring the Nginx One Console, part of the F5 Networks Distributed Cloud ecosystem.

This Overview will show the different features of the Console, and allow you to explore adding, removing, configuring, updating, and monitoring various instances of Nginx OSS and Nginx Plus Docker containers.

NGINX Plus | NGINX One| NGINX OSS
:-------------------------:|:-------------------------:|:-----:
![NGINX Plus](media/nginx-plus-icon.png)  |![Prom](media/nginx-one-icon.png) |![Grafana](media/nginx-icon.png)
  
## Learning Objectives

By the end of the lab you will be able to:

- Login into the Nginx One Console
- Add Nginx OSS and Nginx Plus containers to your inventory
- Explore and review the Nginx and OS Versions
- Explore and review the TLS Certificates
- Explore and follow the Nginx One Recommendations to update your Nginx configurations
- Explore and review the CVEs
- Explore the Nginx One Metrics
- Optional - Explore the Nginx One Console API

## Pre-Requisites

- You must have an F5 Distributed Cloud account, with access to the Nginx One Service.
- You must have the NginxPlus image from Lab1
- You must have Docker installed and running
- You must have Docker-compose installed
- See `Lab0` for instructions on setting up your system for this Workshop
- Familiarity with basic Linux commands and commandline tools
- Familiarity with Docker concepts and commands
- Familiarity with the HTTP protocol

<br/>

## How it Works

The **`Nginx One Console`**, is part of the F5 Networks Distributed Cloud Software as a Service (SaaS) product. This Service provides a Web Console, inventory and storage, and features needed by Nginx administrators.  The Nginx One Service is under constant development and service delivery, as new features are added, enhanced, updated and explanded.  Nginx admins can use the One Console for many kinds of routine opertional and administrative tasks.  This lab exercise is offered as a Test Drive of most of these features.

![NGINX Agent](media/nginx-agent-icon.png) 

The Nginx One Console requires `nginx-agent`, an open source software module written by Nginx that connects and communicates with Nginx One.  This nginx-agent must be installed and running on every Nginx instance that you wish to manage with Nginx One.  You will use the publicly available Nginx with Agent images from Docker Hub for your Nginx OSS containers.  In addition, as part of your Docker Compose file, your NGINX Plus containers already have the required `NGINX Agent` installed for you.  Nginx-agent can also be installed using regular Linux package managers like `apt` and `yum`.  Refer to the References Section for links to the Nginx Agent installation guides.

<br/>

## Login to F5 Distributed Cloud, Nginx One Service

1. Login into your Nginx One Service, using your F5 Distributed Cloud credentials.  The login page can be found at: https://console.ves.volterra.io/login/start

F5 Distributed Cloud Login
:-------------------------:|
![XC Login](media/lab7_xc-login.png) 

1. Click on on the `Nginx One` tile, which will bring you to the Nginx One Console Service Description page.  

Nginx One Console Service
:-------------------------:|
![NOne Service](media/lab7_none-service.png) 

Make sure the Nginx One Console status shows `green - Enabled`.  Click on `Visit Service`.  If it is not enabled, you must request access from your Distributed Cloud admin.
 
This will bring you to the Nginx Console `Overview Dashboard` page - it will show you a collection of Nginx instances, and some Details and Summary panels.

Nginx One Overview Dashboard
:-------------------------:|
![NOne Service](media/lab7_none-dashboard-overview.png) 

If this is your first time logging in or using the Nginx One Console, your Nginx Inventory will be empty.  Have no fear - follow the instructions below to fire up several Nginx containers, which will be added to the Inventory for you:

<br/>

## Create a new Dataplane Key for these lab exercises.

1. Using the Nginx One Console, click on Manage > Instances, then ` + Add instance`.

1. Click on `Generate Dataplane Key`, then copy the value of this key to the clipboard using the `Copy` icon on the right side.  NOTE:  This Dataplane Key is only show here, one time.  Save it locally if you plan to use it again.  You can Register as many Nginx Instances are you like with the same Dataplane Key.  If you lose the Key, just create a new one.

1. After Saving your Key somewhere, scroll down, then click the `Done` button on the bottom right.

## Run Nginx Containers with Docker

Now that you have a Dataplane Key, you can run some Docker containers, using the provided `docker-compose.yml` file.  This Docker Compose will pull and run 9 different Docker Containers, as follows:

- 3 Nginx OSS Containers, with different OS and Nginx versions, connecting to the Nginx One Console
- 3 Nginx Plus Containers, with different OS and Nginx versions, connecting to the Nginx One Console
- 3 nginxinc/ingress-demo Containers, used for the backend web servers, but NOT connected to the Nginx One Console

1. Inspect the `lab7/docker-compose.yml` file.  You will see the details of each container being pulled and run.

>Before you can pull and run these containers, you must set several Environment variables correctly, `before running docker compose`.

1. Using the Visual Studio Terminal, set the `TOKEN` environment variable with the Dataplane Key from the One Console, as follows:

```bash
export TOKEN=paste-your-dataplane-key-from-clipboard-here

```

And verify it was set:

```bash
#check it
echo $TOKEN

```

```bash
## Sample output ##
vJ+ADwlFXKf58bX0Qk/...6N38Al4fdxXDefT6J2iiM=

```

1. Using the same Terminal, set the `JWT` environment variable from your `nginx-repo.jwt` license file.  This is required to pull the Nginx Plus container images from the Nginx Private Registry.   If you do not have an Nginx Plus license, you can request a free 30-Day Trial license from here:  https://www.f5.com/trials/nginx-one 

```bash
export JWT=$(cat nginx-repo.jwt)

```
And verify it was set:

```bash
#check it
echo $JWT

```

1. Using Docker, Login to to the Nginx Private Registry, using the $JWT ENV variable for the username, as follows.  (Your system may require sudo):

```bash
docker login private-registry.nginx.com --username=$JWT --password=none

```
You should see a `Login Suceeded` message, like this:

```bash
## Sample output ##
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
WARNING! Your password will be stored unencrypted in /home/ubuntu/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

```

1. If both ENV variables are set correctly && you are logged into the Nginx Private Registry, you can now run Docker Compose to pull and run the images.  Ensure you are in the `/lab7` folder:

```bash
docker compose up --force-recreate -d

```

You will see Docker pulling the images, and then starting the containers.

![Docker Pulling](media/lab7_none-docker-pulling.png) 

```bash
## Sample output ##
[+] Running 9/10
 ⠙ Network lab7_default    Created                                                               2.1s 
 ✔ Container basics-plus3  Started                                                               0.9s 
 ✔ Container web1          Started                                                               1.4s 
 ✔ Container basics-plus1  Started                                                               2.1s 
 ✔ Container web2          Started                                                               1.8s 
 ✔ Container basics-oss3   Started                                                               2.0s 
 ✔ Container basics-oss1   Started                                                               1.9s 
 ✔ Container basics-oss2   Started                                                               1.6s 
 ✔ Container basics-plus2  Started                                                               1.2s 
 ✔ Container web3          Started                                                               1.2s 

```

1. Verify that all 9 containers started:

```bash
docker ps

```

```bash
## Sample output ##
CONTAINER ID   IMAGE                                                                             COMMAND                  CREATED          STATUS          PORTS                                                                                                                                                                          NAMES
# Nginx OSS containers
00ee8c9e4326   docker-registry.nginx.com/nginx/agent:mainline                                    "/docker-entrypoint.…"   44 minutes ago   Up 44 minutes   0.0.0.0:33396->80/tcp, :::33395->80/tcp, 0.0.0.0:33393->443/tcp, :::33392->443/tcp, 0.0.0.0:33388->9000/tcp, :::33387->9000/tcp, 0.0.0.0:33381->9113/tcp, :::33380->9113/tcp   basics-oss1
34b871d50d1b   docker-registry.nginx.com/nginx/agent:alpine                                      "/docker-entrypoint.…"   44 minutes ago   Up 44 minutes   0.0.0.0:33391->80/tcp, :::33390->80/tcp, 0.0.0.0:33385->443/tcp, :::33384->443/tcp, 0.0.0.0:33378->9000/tcp, :::33377->9000/tcp, 0.0.0.0:33375->9113/tcp, :::33374->9113/tcp   basics-oss2
022d79ce886c   docker-registry.nginx.com/nginx/agent:1.26-alpine                                 "/docker-entrypoint.…"   44 minutes ago   Up 44 minutes   0.0.0.0:33398->80/tcp, :::33397->80/tcp, 0.0.0.0:33395->443/tcp, :::33394->443/tcp, 0.0.0.0:33392->9000/tcp, :::33391->9000/tcp, 0.0.0.0:33386->9113/tcp, :::33385->9113/tcp   basics-oss3

# Nginx Plus containers
9770a4169e19   private-registry.nginx.com/nginx-plus/agent:nginx-plus-r32-alpine-3.20-20240613   "/usr/bin/supervisor…"   44 minutes ago   Up 44 minutes   0.0.0.0:33397->80/tcp, :::33396->80/tcp, 0.0.0.0:33394->443/tcp, :::33393->443/tcp, 0.0.0.0:33389->9000/tcp, :::33388->9000/tcp, 0.0.0.0:33383->9113/tcp, :::33382->9113/tcp   basics-plus1
852667e29280   private-registry.nginx.com/nginx-plus/agent:nginx-plus-r31-alpine-3.19-20240522   "/usr/bin/supervisor…"   44 minutes ago   Up 44 minutes   0.0.0.0:33382->80/tcp, :::33381->80/tcp, 0.0.0.0:33377->443/tcp, :::33376->443/tcp, 0.0.0.0:33374->9000/tcp, :::33373->9000/tcp, 0.0.0.0:33372->9113/tcp, :::33371->9113/tcp   basics-plus2
ffa65b04e03b   private-registry.nginx.com/nginx-plus/agent:nginx-plus-r31-ubi-9-20240522         "/usr/bin/supervisor…"   44 minutes ago   Up 44 minutes   0.0.0.0:33373->80/tcp, :::33372->80/tcp, 0.0.0.0:33371->443/tcp, :::33370->443/tcp, 0.0.0.0:33370->9000/tcp, :::33369->9000/tcp, 0.0.0.0:33369->9113/tcp, :::33368->9113/tcp   basics-plus3

# Nginx Ingress Demo containers (not Registered with One Console)
37c2777c8598   nginxinc/ingress-demo                                                             "/docker-entrypoint.…"   44 minutes ago   Up 44 minutes   0.0.0.0:33387->80/tcp, :::33386->80/tcp, 0.0.0.0:33379->443/tcp, :::33378->443/tcp                                                                                             web1
dba569e76e36   nginxinc/ingress-demo                                                             "/docker-entrypoint.…"   44 minutes ago   Up 44 minutes   443/tcp, 0.0.0.0:33390->80/tcp, :::33389->80/tcp, 0.0.0.0:33384->433/tcp, :::33383->433/tcp                                                                                    web2
5cde3c462a27   nginxinc/ingress-demo                                                             "/docker-entrypoint.…"   44 minutes ago   Up 44 minutes   0.0.0.0:33380->80/tcp, :::33379->80/tcp, 0.0.0.0:33376->443/tcp, :::33375->443/tcp                                                                                             web3

```

Go back to your One Console Instance page, and click `Refresh`.  You should see all 6 of your `basics-`  instances appear in the list, and the Online icon should be `green`.  If they did not Register with the One Console, it is likely you have an issue with the $TOKEN used, create a new Dataplane Key and try again.  It should look similar to this:

Nginx Instances
:-------------------------:|
![Nginx Instances](media/lab7_none-instances.png) 

>Now that the Nginx OSS and Plus containers are running and Registered with the One Console, you can explore the various features of the One Console, and manage your Nginx Instances!

<br/>

## Explore the Nginx One Console Overview Dashboard

Click on the Overview Dashboard, to see the Summary Panels of your Nginx fleet:  

- Availability of your Instances to the Console
- Different Versions of Nginx OSS / Plus being used
- Different Versions of Linux Distros being used 
- The Expiration dates/status of your TLS Certificates
- Expert analysis of your Nginx configurations - and YES!! Nginx AI is coming here :-)
- Any CVEs detected, either with Nginx or the Linux OS
- CPU, RAM, and Disk utilization
- Network Throughput metrics
- Summary of HTTP 400/500 Response Codes

### Availability

This Panel is pretty self explanatory, which of your Nginx Instances is online and communicating with the Console.  Click on the `Online, Offline, or Unavailable` links for more details.  You can add a `Filter` to assist with sorting/displaying your Instances.  Notice there is a `Last Reported Time` column, so you know when the instance last did a handshake with the Console.  Under `Actions`, you can go directly to the Configuration tool, or Delete the Instance.

![Nginx Avail](media/lab7_none-availability.png) 

### Nginx Versions

This Panel shows a Summary of which Nginx Versions are in use and by how many instances.  Sure, you could write a bash script to SSH into every Instance, and query `nginx -v` and collect this data yourself ... but why not use the Console instead?  Do you even *have* `root privleges` to SSH in the first place?  This makes it easy to know which Instances need a patch or an upgrade to Nginx.

![Nginx versions](media/lab7_none-nginx-versions.png) 

### Operating Systems

This Panel shows a Summary of which Linux Distros are in use and by how many instances.  Sure, you could write YABS - yet another bash script - to SSH into every Instance, and query `uname` and collect the versions yourself ... but why not use the Console Easy Button instead ?  As the number of people, teams, and projects grow using Nginx, the Version sprawl can become an issue.  The Console lets you see this level of detail quite easily.  And it makes it easy to find Linux versions that may not be approved by Security for Production, or need a patch applied.

![Linux versions](media/lab7_none-linux-versions.png) 

### Certificates

This Panel shows a Summary of the TLS Certificate expiration Status, using each certificate's expiry date as reported with openssl on each Instance.  Nginx Agent scans the Nginx config files, then uses openssl to query each Certificate file, and reports this information up to the Nginx Console.  If you click on the `Expired, Expiring, Valid, or Not Ready` links, you get additional details on the name of the certificate and on which Instance it can be found.  Once again, this saves you writing another bash script, you can see this TLS metadata at your fingertips.  You will update an expired certificate in the next Exercise.

![Certs](media/lab7_none-certs.png) 

### Configuration Recommendations

This Panel shows some possible improvements that could be made to your current running Nginx configs.  Some are Security related, or an Optimization, or a Best Practice from the experts that built Nginx.  Clicking on each of these will give you additional details and provide an easy way to edit / update your Nginx configs.  You will do this in the next Exercise.

![Config recommendations](media/lab7_none-config-recommendations.png) 

### CVEs

This Panel is a great tool to show you the CVEs that you might have in your Nginx fleet, with `High-Medium-Low Severity` classes, and which Instances are affected.  Even better, click on the CVE hyperlink takes you directly to the CVE website for detailed information, and possible remediations.

![CVEs](media/lab7_none-cves.png) 

### CPU, RAM, Disk Utilization

This Panel shows basic Host level information from the Linux OS about the consumption of hardware resources that the Nginx Agent reports to the One Console.  There is a `time selector` to show these metrics over different periods of time, with a history graph plotted for you.  Click the `See All` button for a columnar list, which you can Filter and Sort.

![Cpu](media/lab7_none-cpu.png) 
![Ram](media/lab7_none-ram.png) 
![Disk](media/lab7_none-disk.png) 

### Unsuccessful Response Codes

The Nginx Agent scans the Access logs and summarizes the number of 4xx and 5xx HTTP Return codes found, and reports this information the One Console.  There is time selector, and a See All button for this Panel as well. 

![Response Codes](media/lab7_none-response-codes.png) 

### Top Network Usage

This Panel shows basic Network level information from the Linux OS about the network traffic that the Nginx Agent reports to the One Console.  There is a `time selector` to show these metrics over different periods of time, with a history graph plotted for you.  Click the `See All` button for a columnar list, which you can Filter and Sort.

![Top Network](media/lab7_none-network.png) 

#### Optional:  How to Pull and Run individual containers

If you would like to just run a few containers without Docker Compose, here are some examples to try.  Notice that the `$TOKEN with Dataplane Key` must be set and used for Registration with the Nginx One Console:

1. Run an OSS container, with Debian Linux, called `workshop1` using the $TOKEN variable, as follows.

    ```bash
    sudo docker run \
    --name=workshop1
    --hostname=workshop1
    --env=NGINX_AGENT_SERVER_GRPCPORT=443 \
    --env=NGINX_AGENT_SERVER_HOST=agent.connect.nginx.com \
    --env=NGINX_AGENT_SERVER_TOKEN=$TOKEN \
    --env=NGINX_AGENT_TLS_ENABLE=true \
    --restart=always \
    --runtime=runc \
    -d docker-registry.nginx.com/nginx/agent:mainline

    ```

1. Run a second OSS container running Alpine Linux called `workshop2`, as follows:

    ```bash
    sudo docker run --name=workshop2 --hostname=workshop2 --env=NGINX_AGENT_SERVER_GRPCPORT=443 --env=NGINX_AGENT_SERVER_HOST=agent.connect.nginx.com --env=NGINX_AGENT_SERVER_TOKEN=$TOKEN --env=NGINX_AGENT_TLS_ENABLE=true --restart=always --runtime=runc -d docker-registry.nginx.com/nginx/agent:alpine

    ```

1. Run a third OSS container running Nginx 1.26 / Alpine Linux called `workshop3`, as follows:

    ```bash
    sudo docker run --name=workshop3 --hostname=workshop3 --env=NGINX_AGENT_SERVER_GRPCPORT=443 --env=NGINX_AGENT_SERVER_HOST=agent.connect.nginx.com --env=NGINX_AGENT_SERVER_TOKEN=$TOKEN --env=NGINX_AGENT_TLS_ENABLE=true --restart=always --runtime=runc -d docker-registry.nginx.com/nginx/agent:1.26-alpine

    ```

#### Nginx Instances with Nginx Agent for Nginx One Console use

For Reference:  Find all the currently available Nginx OSS containers with Agent installed.  Curl the `Docker Registry`:

```bash
curl https://docker-registry.nginx.com/v2/nginx/agent/tags/list  | jq

```

For Reference:  Find all the currently available NginxPlus containers with Agent installed.  Curl the `Nginx Private Registry`, you will need your `nginx-repo Cert and Key` files for this command:

```bash
curl https://private-registry.nginx.com/v2/nginx-plus/agent/tags/list --key nginx-repo.key --cert nginx-repo.crt | jq

```
<br/>

## Nginx One Certificates Overview

< tls icon here >

Another nice feature of the Nginx One Console is the ability to quickly see the `Expiration Dates of the TLS Certificates` being used by your Nginx Instances.  When the nginx-agent reads the Nginx configuration, it looks for the TLS certificate path/name, and uses openssl to collect the Certificate Expiration date, and sends this information to the One Console.  It provides both a Summary of all the certificates, and the details on each one.  Sure, you can write an bash script to login with root privleges to every Nginx Server, and collect this information yourself.  But using the Nginx One Console makes this easy to see and help plan appropriate actions.  There is one caveat to this feature, it only scans the TLS certificates that are part of the running Nginx configuration of the Instance, it does not check additional TLS certificates, even if they are in the same location on disk.

1. Create a new 91-day SSL certificate/key, and apply it to your configuration:

```bash
openssl req -x509 -nodes -days 91 -newkey rsa:2048 -keyout 91-day.key -out 91-day.crt -subj "/CN=NginxPlusBasics"

```

## Nginx One Config Recommendations Overview


## Nginx One CVEs Overview



<br/>

## Wrap UP

>If you are finished with this lab, you can use Docker Compose to shut down your test environment. Make sure you are in the `lab7` folder:

```bash
docker compose down

```

```bash
##Sample output##
[+] Running 10/10
 ✔ Container basics-oss3   Removed                                                               6.4s 
 ✔ Container basics-plus2  Removed                                                              10.7s 
 ✔ Container web1          Removed                                                               0.5s 
 ✔ Container basics-oss1   Removed                                                               5.5s 
 ✔ Container web2          Removed                                                               0.4s 
 ✔ Container basics-plus1  Removed                                                              10.7s 
 ✔ Container web3          Removed                                                               0.5s 
 ✔ Container basics-oss2   Removed                                                               6.2s 
 ✔ Container basics-plus3  Removed                                                              10.6s 
 ✔ Network lab7_default    Removed                                                               0.1s 

```

Don't forget to stop all of the Nginx containers if you are finished with them, and Delete them from the Nginx One Instance inventory.

<br/>

**This completes Lab7.**

<br/>

## References:

- [Nginx One Console](https://docs.nginx.com/nginx-one/)
- [Nginx Agent](https://docs.nginx.com/nginx-agent/overview/)
- [NGINX Plus](https://www.nginx.com/products/nginx/)
- [NGINX Admin Guide](https://docs.nginx.com/nginx/admin-guide/)
- [NGINX Technical Specs](https://docs.nginx.com/nginx/technical-specs/)



<br/>

### Authors

- Chris Akker - Solutions Architect - Community and Alliances @ F5, Inc.
- Shouvik Dutta - Solutions Architect - Community and Alliances @ F5, Inc.
- Adam Currier - Solutions Architect - Community and Alliances @ F5, Inc.

-------------

Navigate to ([Main Menu](../readme.md))