# Module Title

## Intro

Nginx  has a phenomenal logging facility which is highly customizable. In this module, we will explain how to configure you own formats for access and error logs for Nginx in Linux.



## Task 1: Enable virtual server specifc Error and Access logs for www.example.com

A best practice is to set up individual log files for each of your virtual servers in order to reduce the size of each log file, this makes troubleshooting easier and log rotation less frequent.

1. Uncomment the lines enabling server specific logging for www.example.com virtual server:

```nginx
# /etc/nginx/conf.d/example.com.conf 

    # Server specific logging
    access_log  /var/log/nginx/www.example.com.log  main_cache; 
    error_log   /var/log/nginx/www.example.com_error.log error; 
```

2. Save the the file and reload nginx:

```bash
# With sudo or as root
nginx -t && nginx -s reload
```

3. On the NGINX Plus server, use `tail` to output the access logs as they are written:

```bash
tail -f /var/log/nginx/www.example.com.log
```

4. Run some traffic to `www.example.com` 

## Task 2
