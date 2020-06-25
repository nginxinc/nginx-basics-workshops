#  Custom Access Log Formats

## Introduction

In this module, we will explain how to configure Server specific 
[Access log](http://nginx.org/en/docs/http/ngx_http_log_module.html#access_log) and [Error logs](http://nginx.org/en/docs/ngx_core_module.html#error_log) using custom log formats

Nginx's logging facility is highly customizable and allows you to add custom  (variables)[http://nginx.org/en/docs/varindex.html] 
into your logs for purposes of verbose debugging, troubleshooting or analysis of what unfolds within your applications served by NGINX

**References:** 
 * [Configuring Logging](https://docs.nginx.com/nginx/admin-guide/monitoring/logging)

## Task 1: Enable virtual server specifc Error and Access logs for www.example.com

A best practice is to set up individual log files for each of your virtual servers in order to reduce the size of each 
log file, this makes troubleshooting easier and log rotation less frequent.

1. Uncomment the lines enabling server specific logging for www.example.com virtual server:

```nginx
# /etc/nginx/conf.d/example.com.conf 

    # Server specific logging
    access_log  /var/log/nginx/www.example.com.log  main_cache; 
    error_log   /var/log/nginx/www.example.com_error.log error; 
```

2. You can see the custom log format defined as json_ext in `/etc/nginx/includes/log_formats/extended_log_formats.conf`

3. Save the the file and reload nginx:

```bash
# With sudo or as root
nginx -t && nginx -s reload
```

4. On the NGINX Plus server, use `tail` to output the access logs as they are written:

```bash
tail -f /var/log/nginx/www.example.com.log
```

5. Run some traffic to [`http://www.example.com`](http://www.example.com) From a web browser or using curl 
   `curl http://www.example.com`

6. We now can see our custom access log written to file

```bash
tail -f /var/log/nginx/www.example.com.log

remote_addr="172.18.0.1", [time_local=24/Jun/2020:16:10:25 +0000], request="GET / HTTP/1.1", status="200", http_referer="-", body_bytes_sent="7231", gzip_ratio="-", http_user_agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36 OPR/69.0.3686.36", http_x_forwarded_for="-", Host="www.example.com", sn="www.example.com", request_time=0.001, request_length="455", upstream_address="172.18.0.3:80", upstream_status="200", upstream_connect_time="0.000", upstream_header_time="0.000", upstream_response_time="0.000", upstream_response_length="7225", upstream_cache_status="-", http_range="-", slice_range="-" 
remote_addr="172.18.0.1", [time_local=24/Jun/2020:16:10:26 +0000], request="GET / HTTP/1.1", status="200", http_referer="-", body_bytes_sent="7231", gzip_ratio="-", http_user_agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36 OPR/69.0.3686.36", http_x_forwarded_for="-", Host="www.example.com", sn="www.example.com", request_time=0.000, request_length="455", upstream_address="172.18.0.4:80", upstream_status="200", upstream_connect_time="0.000", upstream_header_time="0.000", upstream_response_time="0.000", upstream_response_length="7225", upstream_cache_status="-", http_range="-", slice_range="-" 
remote_addr="172.18.0.1", [time_local=24/Jun/2020:16:10:31 +0000], request="GET / HTTP/1.1", status="200", http_referer="-", body_bytes_sent="7232", gzip_ratio="-", http_user_agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36 OPR/69.0.3686.36", http_x_forwarded_for="-", Host="www.example.com", sn="www.example.com", request_time=0.001, request_length="455", upstream_address="172.18.0.2:80", upstream_status="200", upstream_connect_time="0.000", upstream_header_time="0.000", upstream_response_time="0.000", upstream_response_length="7225", upstream_cache_status="-", http_range="-", slice_range="-
```

## Task 2: Enable JSON format Access logs for www2.example.com

We can also configure NGINX to write logs in JSON format. This may be a requirement or preference for popular log 
collectors and log servers.

We can use `escape=json` parameter that sets JSON valid character escaping. You need to have all non-word characters in 
JSON escaped with unicode style like this: `\uNNNN`. This is how our current nginx JSON log_format looks like:


1. Uncomment the lines enabling server specific logging for www.example.com virtual server:

```nginx
# /etc/nginx/conf.d/www2.example.com.conf 

    # Server specific logging
    access_log  /var/log/nginx/www2.example.com.log  json_ext; 
    error_log   /var/log/nginx/www2.example.com_error.log error; 
```

2. You can see the custom log format defined as json_ext in `/etc/nginx/includes/log_formats/json_log_formats.conf`

3. Save the the file and reload nginx:

```bash
# With sudo or as root
nginx -t && nginx -s reload
```

4. On the NGINX Plus server, use `tail` to output the access logs as they are written:

```bash
tail -f /var/log/nginx/www2.example.com.log
```

5. Run some traffic to [`https://www2.example.com`](https://www2.example.com) From a web browser or using curl 
   `curl -k https://www2.example.com`

6. We now can see our custom access log written to file

```bash
tail -f /var/log/nginx/www2.example.com.log

{"proxy_protocol_addr": "","remote_user": "","remote_addr": "172.18.0.1","time_local": "24/Jun/2020:16:25:49 +0000","request" : "GET / HTTP/1.1","status": "200","body_bytes_sent": "7231","http_referer": "","http_user_agent": "curl/7.68.0","http_x_forwarded_for": "","proxy_add_x_forwarded_for": "172.18.0.1","host": "host","server_name": "www2.example.com","request_length" : "80","request_time" : "0.000","proxy_host": "nginx_hello","upstream_addr": "172.18.0.3:80","upstream_response_length": "7225","upstream_response_time": "0.004","upstream_status": "200"}
```

```json
# Or piping into jq for fancy JSON formating 
tail -f /var/log/nginx/www2.example.com.log | jq '.'
{
  "proxy_protocol_addr": "",
  "remote_user": "",
  "remote_addr": "172.18.0.1",
  "time_local": "24/Jun/2020:16:29:03 +0000",
  "request": "GET / HTTP/1.1",
  "status": "200",
  "body_bytes_sent": "7231",
  "http_referer": "",
  "http_user_agent": "curl/7.68.0",
  "http_x_forwarded_for": "",
  "proxy_add_x_forwarded_for": "172.18.0.1",
  "host": "host",
  "server_name": "www2.example.com",
  "request_length": "80",
  "request_time": "0.001",
  "proxy_host": "nginx_hello",
  "upstream_addr": "172.18.0.3:80",
  "upstream_response_length": "7225",
  "upstream_response_time": "0.000",
  "upstream_status": "200"
}
```
