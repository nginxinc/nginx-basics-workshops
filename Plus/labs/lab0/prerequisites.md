# Preparing your Computer for the NGINX Basics Workshop

## Introduction

In order to complete the Lab exercises in this Workshop on your own computer and not use the F5 provided workshop environment, your computer should meet with the following license, hardware, software, and access requirements. If you are unable to meet these basic requirements, you will likely not be able to complete the Labs as written.  It is highly recommended that you have the minimum requirements.

## Learning Objectives

By the end of this Prerequisite instructions, you will be ready to do the Workshop lab exercises in your own system.

## NGINX Plus License Requirements

1. You must have an NGINX Plus Commercial license/subscription for this Workshop.
2. You must download the `nginx-repo.crt` and `nginx-repo.key` and `nginx-repo.jwt` files from your MyF5 account.
3. If you do not have a current license, you can request a 30-Day Trial License for free, here: https://www.f5.com/trials/nginx-one . It takes several minutes for the F5 Licensing system to send you an email, with a `one-time download link` to the License files.  `Save the nginx-repo.* files to your local storage`, you will need them before you start the Workshop.  (NOTE: the nginx-repo.jwt file is not needed for this workshop, but download it for the Nginx Plus Ingress Workshop if you are interested in learning about Nginx Plus Ingress Controller for Kubernetes - your next NGINXperts Workshop!).
4. If you do not have access to Nginx Plus, you can still take the NGINX OSS Basics Workshop, and get familiar with NGINX Open Source.

## F5 Distributed Cloud Accout

You will need an F5 Distributed Cloud account to complete the Nginx ONE Console lab exercises.  If you do not have an Account, please contact your F5 Sales Representative for more information.

## Hardware Requirments

1. 8GB available RAM
2. 50GB available disk space
3. Recommended - second monitor

## Software Requirements

1. Git
1. Docker Engine
1. Docker Compose
1. Chrome or other modern browser
1. Visual Studio Code, or other test/code editor
1. Thunder Client VSCode extension or any other API platform that helps running API requests.

## Administrative Requirements

1. Network connection to the Internet
1. Admin access to install software, Copy and Edit local files
1. Admin access to control Network Firewalls and VPN settings
1. Admin access to configure local DNS hosts file

## Install Docker Engine

- [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)

## Install Docker Compose

- [https://docs.docker.com/compose/install/](https://docs.docker.com/compose/install/)

## Optional - Install Visual Studio Code

- [https://code.visualstudio.com/download](https://code.visualstudio.com/download)

## Optional - Install Thunder Client extension Tool

- [https://www.thunderclient.com/](https://marketplace.visualstudio.com/items?itemName=rangav.vscode-thunder-client)

## Cloning the Workshop Repository locally

Once you have setup your system make sure to clone this repository locally in your system.

```bash
git clone https://github.com/nginxinc/nginx-basics-workshops.git

```

<br/>
You are now prepared to start with the workshop labs.
<br/>

## References:

- [NGINX Plus](https://docs.nginx.com/nginx/)
- [NGINX Free 30-Day Trial](https://www.f5.com/trials/free-trial-nginx-plus-and-nginx-app-protect)
- [NGINX Admin Guide](https://docs.nginx.com/nginx/admin-guide/)
- [NGINX Technical Specs](https://docs.nginx.com/nginx/technical-specs/)

<br/>

### Authors

- Chris Akker - Solutions Architect - Community and Alliances @ F5, Inc.
- Shouvik Dutta - Solutions Architect - Community and Alliances @ F5, Inc.
- Adam Currier - Solutions Architect - Community and Alliances @ F5, Inc.

-------------

Navigate to ([Lab1](../lab1/readme.md) | [Main Menu](../readme.md))