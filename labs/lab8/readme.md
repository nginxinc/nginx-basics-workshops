# NGINX Plus with Prometheus and Grafana

## Introduction

In this lab, you will be exploring the integration between NGINX Plus, Prometheus and Grafana.

This Solution requires the use of the NGINX provided JaveScript and Prometheus modules to collect metrics from the NGINX Plus API, and export those metrics as an HTTP html/text page, commonly called the `scaper page` because it scrapes statistics for publication.  The metrics on this export page are then read and imported into Prometheus and Grafana's time-series database.  Once these metrics are in the database, you can create many different Dashboards, Thresholds, Alerts, and other types of graphs for Visualization and Reporting.  As you can imagine, there are literally hundreds of Grafana dashboards written by users of NGINX that you can try out for free.  Grafana also allows you to create and edit your own Dashboards.

NGINX Plus | Prometheus | Grafana
:-------------------------:|:-------------------------:|:-----:
![NGINX Plus](media/nginx-plus-icon.png)  |![Prom](media/prometheus-icon.png) |![Grafana](media/grafana-icon.png)
  
## Learning Objectives

By the end of the lab you will be able to:

- Install and enable NJS - NGINX Java Script
- Create Prometheus Exporter configuration
- Run a Docker based Prometheus Server
- Run a Docker based Grafana Server
- View various Grafana Dashboards

## Pre-Requisites

- You must have Docker installed and running
- You must have Docker-compose installed
- You must an NGINX Plus license, Trial or subscription
- See `Lab0` for instructions on setting up your system for this Workshop
- Familiarity with basic Linux commands and commandline tools
- Familiarity with basic Docker concepts and commands
- Familiarity with basic HTTP protocol
- Familiarity with Prometheus
- Familiartiy with Grafana

As part of your Dockerfile, your NGINX Plus container already has the added `NGINX Java Script and NGINX Prometheus dynamic modules` installed during the build process.  Refer to the Dockerfile if you want to check it out.

1. Edit your `nginx.conf` file, you will make 2 changes.  1.  Uncomment Line #9 to enable the `ngx_http_js_module` module.  2.  Uncomment Line #38 to set a parameter for an NGINX buffer called `subrequest_output_buffer_size`.

    ```nginx
    ...snip

    user  nginx;
    worker_processes  auto;

    error_log  /var/log/nginx/error.log notice;
    pid        /var/run/nginx.pid;

    # Uncomment to enable NGINX JavaScript module
    load_module modules/ngx_http_js_module.so;   # Added for Prometheus

    ...snip

        # Uncomment for Prometheus scraper page output
        subrequest_output_buffer_size 32k;       # Added for Prometheus

    ...snip

    ```

1. Inspect the `prometheus.conf` file.  This is the NGINX config file which opens up port 9113, and provides access to the scraper page.  Uncomment all the lines to enable this.

    ```nginx
    # NGINX Plus Prometheus configuration, for HTTP scraper page
    # Chris Akker, Shouvik Dutta - Feb 2024
    # https://www.nginx.com/blog/how-to-visualize-nginx-plus-with-prometheus-and-grafana/
    # Nginx Basics
    #
    # Uncomment all lines below
    js_import /usr/share/nginx-plus-module-prometheus/prometheus.js;

    server {
    
    listen 9113;               # This is the default port for Prometheus scraper page
        
        location = /metrics {
            js_content prometheus.metrics;
        }

        location /api {
            api;
        } 

    }

    ```

1.  Test the Prometheus scraper page.  Open your browser to http://localhost:9113/metrics.  You see an html/text page like this one.  Click refresh a couple times, and some of the metrics should increment.

< scraper page screenshot here>

<br/>


## Prometheus and Grafana Server Docker containers

<br/>

![](../media/prometheus-icon.png)  |![](../media/grafana-icon.png)
--- | ---

You will run 2 additional Docker containers, one for the Prometheus Server, and one for the Grafana Server.

<br/>

Here are the instructions to run 2 Docker containers in your lab environment, which will collect the NGINX Plus statistics from Prometheus, and graph them with Grafana.  Likely, you already have these running in your environment, but are provided here as an example to display the NGINX Plus metrics of high value.

<br/>

### Prometheus

<br/>

1. Configure your Prometheus server to collect NGINX Plus statistics from the scraper page.  Use the prometheus.yml file provided, edit the `targets` to match your NGINX Plus container name and port of the scraper page.

    ```bash
    cat prometheus.yml

    ```

    ```yaml
    global:
      scrape_interval: 15s 
      
      external_labels:
        monitor: 'nginx-monitor'
    
    scrape_configs:  
      - job_name: 'prometheus'
        
        scrape_interval: 5s
    
        static_configs:
          - targets: ['nginx-plus:9113]  # NGINX Plus container:port

    ```

1. Review, edit and place your `prometheus.yml` file in /etc/prometheus folder.

1. Start the Prometheus docker container:

    ```bash
    sudo docker run --restart always --network=lab8_default -d -p 9090:9090 --name=prometheus -v /Users/akker/Downloads/KIC/nginxinc/nginx-basics-workshops/labs/lab8/nginx-plus/etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus

    ```

1. Prometheus Web Console access to the data is on http://localhost:9090.

    Explore some of the metrics available.  Try a query for `nginxplus_http_requests_total`:

    ![NGINX Prom HTTP Requests](../media/prometheus-upstreams.png)

    >Wow, look at the variance in performance / response time!

<br/>

### Grafana 

<br/>

1. Create a docker volume to store the Grafana data.

    ```bash
    docker volume create grafana-storage

    ```

1. Start the Grafana docker container:

    ```bash
    docker run --restart always -d -p 3000:3000 --name=grafana --network=lab8_default -v grafana-storage:/var/lib/grafana grafana/grafana

    ```

1. Web console access to Grafana is on http://localhost:3000.  The default Login should be user/pass of `admin/admin`.

1. You can import the provided `grafana-dashboard.json` file to see the NGINX Plus `Cluster1 and 2 statistics` HTTP RPS and Upstream Response Times.

<br/>

**This completes Lab8.**

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

Navigate to ([Lab9](../lab8/readme.md) | [Main Menu](../readme.md))