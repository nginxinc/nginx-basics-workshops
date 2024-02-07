# NGINX Web Server with TLS

## Introduction

In this Lab, NGINX as an HTTPS webserver with TLS termination will be introduced.  HTTPS is commonly used to secure a website with encryption, so that data sent between the browser and the NGINX server cannot be easily read like HTTP. You will explore common TLS configuration directives and variables, to provide encryption for your traffic.  You will also explore some common tools to create and test TLS encryption components.

## Learning Objectives 

By the end of the lab you will be able to: 
 * Create a Self Signed TLS certificate and key
 * Configure NGINX webserver to use a TLS cert and key
 * Configure TLS settings
 * Add some TLS Best Practice configurations
 * Test and validate TLS traffic components and settings

</br>

## Prerequisites

<br/>

- You must have Docker installed and running
- You must have Docker-compose installed
- See `Lab0` for instructions on setting up your system for this Workshop
- Familiarity with basic Linux commands and commandline tools
- Familiarity with basic Docker concepts and commands
- Familiarity with basic HTTP and HTTPS protocols

<br/>

## Create TLS Self Signed Certificate and Key

In this exercise, you will use `openssl` to create a Self Signed certificate and key to use for these exercises.  However, it should be clearly understood, that Self-Signed certificates are exactly that - they are created and signed by you or someone else.  `They are not signed by any official Certificate Authority`, so they are not recommended for any use other than testing in local lab exercises.  Most Modern Internet Browsers will display Security Warnings when they receive a Self-Signed certificate from a webserver.  In some environments, the Browser will block access completely.  So use Self Signed certificates with `CAUTION`.

1. Ensure you are in the `lab3` folder.  Using a Terminal, use Docker Compose to build and run the `nginx-oss` container.  This is a new image, based on the Dockerfile in the lab3 folder.  The `openssl` libraries have been added, so you can use them to build, configure, and test TLS.

1. After the Docker Compose has completed, and the lab3/nginx-oss container is running, Docker Exec into the nginx-oss container.

    ```bash
    docker exec -it <lab3 nginx-oss Container ID> /bin/bash

    ```

1. Change to the /etc/ssl folder, and create a new folder called nginx:

    ```bash
    cd /etc/ssl
    mkdir -p nginx

    ```

1. Change directory to this new nginx folder.  Using openssl, create a new self-signed TLS certificate and key files.  You will be using these to provide TLS for your `cars.example.com` website:

    ```bash
    cd nginx

    /etc/ssl/nginx $ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout cars.example.com.key -out cars.example.com.crt -subj "/CN=NginxBasics"

    ```

    Quick explanation of the `openssl` command above:

    - Create a new x509 compatible certificate
    - Expiration is one year, 365 days
    - Use 2048 bit RSA encryption
    - Use TLS Subject Name "NginxBasics"
    - Name the files cars.example.com.crt, and cars.example.com.key

1. Verify the files were created, list them in the folder, and use `cat` to look at them:

    ```bash
    /etc/ssl/nginx $ ls -l

    ```

    ```bash
    #Sample output
    total 8
    -rw-r--r--    1 root     root          1119 Feb  5 19:40 cars.example.com.crt
    -rw-------    1 root     root          1708 Feb  5 19:40 cars.example.com.key

    ```

    ```bash
    /etc/ssl/nginx $ cat cars.example.com.crt

    ```

    ```bash
    #Sample output
    -----BEGIN CERTIFICATE-----
    MIIDDTCCAfWgAwIBAgIUdPfXtRGjRfM9H72saPaB0iFxfukwDQYJKoZIhvcNAQEL
    ...snip
    FEW+0L1jGJzuvVtP0LwIywc=
    -----END CERTIFICATE-----

    ```
    ```bash
    /etc/ssl/nginx $ cat cars.example.com.key

    ```

    ```bash
    #Sample output
    -----BEGIN PRIVATE KEY-----
    MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDc8eIOHsfGOop1
    ...snip
    SHa8zigyl3iYJAenhMSat74Rng==
    -----END PRIVATE KEY-----

    ```

<br/>

NGINX | TLS
:----:|:----:
![NGINX](media/nginx-icon.png) | ![Padlock](media/padlock-icon.png)

## NGINX webserver with TLS

<br/>

Now that you have a TLS cert and key for testing, you will configure NGINX to use them. 

*NOTE:*  If you have a real TLS cert and key issued by a Certificate Authority, you can use those files in this exercise if you like, just copy them to the docker container, and use the configuration commands below.

1. Docker Exec into your nginx-oss container as before. 

1. Using VI, make the following changes to your tls-cars.example.com.conf file:

    1. On line #1, change the comment from HTTP to HTTPS
    1. On line #7, change the `listen 80` directive to `listen 443 ssl`.
    1. Insert 2 new lines, between the server_name and access_log lines:
    - ssl_certificate /etc/ssl/nginx/cars.example.com.crt;
    - ssl_certificate_key /etc/ssl/nginx/cars.example.com.key;

1. Your updated `tls-cars.example.com.conf` should look similar to this:

    ```nginx
    # cars.example.com HTTPS                # updated comment
    # NGINX Basics Workshop
    # Jan 2024, Chris Akker, Shouvik Dutta
    #
    server {
        
        listen 443 ssl;  # change to port 443, add "ssl" parameter for terminating TLS on all IP addresses on this machine

        server_name cars.example.com;   # Set hostname to match in request

    # Add the following 2 lines for NGINX cert and key directives and file locations

        ssl_certificate /etc/ssl/nginx/cars.example.com.crt;
        ssl_certificate_key /etc/ssl/nginx/cars.example.com.key; 

        access_log  /var/log/nginx/cars.example.com.log main; 
        error_log   /var/log/nginx/cars.example.com_error.log notice;

        root /usr/share/nginx/html;         # Set the root folder for the HTML and JPG files

        location / {
            
            default_type text/html;
            return 200 "Let's go fast, you have reached cars.example.com, path $uri\n";
        }
        
        location /gtr {
            
            try_files $uri $uri.html;         # Look for filename that matches the URI requested
        }
        
        location /nsx {
            
            try_files $uri $uri.html;
        }
        
        location /rcf {
            
            try_files $uri $uri.html;
        }

        location /browse {                   # new URL path
            
            alias /usr/share/nginx/html;     # Browse this folder
            index index.html;                # Use this file, but if it does *not* exist
            autoindex on;                    # Perform directory/file browsing
        }

    } 

    ```

    Save your file.

1. Test and reload your NGINX configuration.

1. Now give a try with curl, using a Terminal on your local machine. 

    ```bash
    curl https://cars.example.com

    ```

    ```bash
    #Sample output

    curl: (60) SSL certificate problem: self signed certificate
    More details here: https://curl.se/docs/sslcerts.html

    curl failed to verify the legitimacy of the server and therefore could not
    establish a secure connection to it. To learn more about this situation and
    how to fix it, please visit the web page mentioned above.

    ```

    As you can see, `curl reports with an error` that the certificate is Self Signed, and refuses to complete the request!  Adding the `-k` switch is `-insecure`, which tells curl to ignore this error - this is required for Self Signed certificates.  Give that a try:

    ```bash
    curl -k https://cars.example.com

    ```

    ```bash
    #Sample output
    Let's go fast, you have reached cars.example.com, path /

    ```

    > Congrats!  You have just enabled TLS on your webserver with only 3 NGINX commands (smiling emoji here!).


1. Now try it with a browser, go to https://cars.example.com.  YIKES - what's this??  Most modern browsers will display an `Error or Security Warning`:

    ![Certificate Invalid](media/lab3_cert-invalid.png)

1. You can use Chrome's built-in Certificate Viewer to look at the details of the TLS certificate that was sent from NGINX to your browser.  In the address bar, click on the `Not Secure` icon, then `Cerificate is not valid`, and it will display the certificate.  Who provided this Invalid Certificate ??  - well, you did.

    ![Certificate Details](media/lab3_cert-details.png)


1. With Chrome, Close the Certificate Viewer, and then you have to click on the Advanced button, and then the Proceed link, to bypass the Warning and continue.  

    >>CAUTION:  Ignoring Browser Warnings is **Dangerous**, only Ignore these warnings if you are 100% sure it is safe to proceed!!

1. After you safely Proceed, you should see the cars.example.com `Let's go fast` message.  

    ![Cars Proceed](media/lab3_cars-proceed.png)

1. Re-test all your cars.example.com URLs using HTTPS, ( /gtr, /nsx, /rcf, /browse ) they should all work the same as before, but now NGINX is using TLS to encrypt the traffic.

### Enable HTTP > HTTPS redirect

Now that you have a working TLS configuration, you decide to use it for every user.  However, sometimes users forget to type the `S` with `http`, or saved the URL as a bookmark, and come to your NGINX server with an HTTP request on port 80.  You will configure a helpful HTTP to HTTPS re-direct, to automagically send all users over to your HTTPS configuration.

1. Change to the `/etc/nginx/conf.d` folder, and edit your existing `cars.example.com.conf file`.  On line #7, Change the `listen 80` directive to `listen 81`.  This will change the listen port, so it won't have a conflict, like this:

    ```nginx
    # cars.example.com HTTP on port 81              # Did you update your comments?
    # NGINX Basics Workshop
    # Jan 2024, Chris Akker, Shouvik Dutta
    #
    server {
    
       listen 81;      ### Change only this line to port 81 ###

       server_name cars.example.com;   # Set hostname to match in request
    
    # Rest of the config snipped
    ...

    ```

    Save your file.  Test and Reload NGINX.
    
    This will move `cars.example.com` from Port 80 to Port 81, so that you can use Port 80 in the tls-cars.example.com config without a port 80 conflict.  NGINX will not let you use `listen 80` in two different config files with the same server name.  If you try this, the `nginx -t` test will give you a [warn] message. 
    
    (*NOTE:  Normally, you could just rename the cars.example.com.conf file to a different name so NGIINX would not use it, but Docker will not let you do that here because you mounted this file as a volume in docker-compose for this exercise.*)

    >BONUS:  If you test this website http://cars.example.com:81 on port 81, you will discover that it works fine while you are `inside` the Docker Exec of the container, but does not work from a Terminal `outside` the container.  Can you explain why??

   <details><summary>Click for Answer!</summary>
   <br/>
   <p>
   <strong>Answer</strong> – the nginx-oss Docker Container is not open on Port 81!  You would need to update your docker-compose file, and add port 81 to the list, and rebuild your nginx-oss container.  Remember, that networking with Docker can require some inside/outside matching configurations.  As a stretch goal, you could update your container and give it a try.
   </p>
   </details>
   </br>

1. Edit your `tls-cars.example.com.conf` file, and make these changes:

    - Update Line #1 comment, to include both HTTP and HTTPS configurations
    - Insert a new server block, for port 80, with the re-direct enabled for all URLs

    ```nginx

    # cars.example.com with HTTP > HTTPS                 # updated comment
    # NGINX Basics Workshop
    # Jan 2024, Chris Akker, Shouvik Dutta
    #
    ### New Server block for port 80
    server {
        
        listen 80;      # Listening on port 80 on all IP addresses on this machine

        server_name cars.example.com;   # Set hostname to match in request

        location / {
            
            return 301 https://$host$request_uri;        # Send 301 redirect to HTTPS
        }
    }

    ### End of new Server block for port 80

        server {
        
        listen 443 ssl;   # change to port 443, add "ssl" parameter for terminating TLS on all IP addresses on this machine

        server_name cars.example.com;   # Set hostname to match in request

    # Add the following 2 lines for NGINX cert and key directives and file locations

        ssl_certificate /etc/ssl/nginx/cars.example.com.crt;
        ssl_certificate_key /etc/ssl/nginx/cars.example.com.key;

        access_log  /var/log/nginx/cars.example.com.log main; 
        error_log   /var/log/nginx/cars.example.com_error.log notice;

        root /usr/share/nginx/html;         # Set the root folder for the HTML and JPG files

        location / {
            
            default_type text/html;
            return 200 "Let's go fast, you have reached cars.example.com, path $uri\n";
        }
        
        location /gtr {
            
            try_files $uri $uri.html;         # Look for filename that matches the URI requested
        }
        
        location /nsx {
            
            try_files $uri $uri.html;
        }
        
        location /rcf {
            
            try_files $uri $uri.html;
        }

        location /browse {                   # new URL path
            
            alias /usr/share/nginx/html;     # Browse this folder
            index index.html;                # Use this file, but if it does *not* exist
            autoindex on;                    # Perform directory/file browsing
        }

    } 

    ```

    Save your file.  Test and reload NGINX.

1. Test out your redirect with curl, adding the `-I` parameter to show just the Headers:

    ```bash
    curl -I http://cars.example.com

    ```

    It should look something like this:

    ```
    #Sample output
    HTTP/1.1 301 Moved Permanently
    Server: nginx/1.25.3
    Date: Tue, 06 Feb 2024 23:22:06 GMT
    Content-Type: text/html
    Content-Length: 169
    Connection: keep-alive
    Location: https://cars.example.com/

    ```

    Now let's follow the re-direct, with `-L`, and `-k` for insecure - does that work?

    ```bash
    curl -ILk http://cars.example.com
    
    ```

```
#Sample output
HTTP/1.1 301 Moved Permanently
Server: nginx/1.25.3
Date: Wed, 07 Feb 2024 00:09:41 GMT
Content-Type: text/html
Content-Length: 169
Connection: keep-alive
Location: https://cars.example.com/    # Redirected to here

HTTP/1.1 200 OK
Server: nginx/1.25.3
Date: Wed, 07 Feb 2024 00:09:41 GMT
Content-Type: text/html
Content-Length: 57
Connection: keep-alive

```

Let's check it with your browser.  These instructions are for Chrome, they will differ slightly for other browsers.


<br/>

**This completes this Lab.**

<br/>

## References:

- [NGINX Beginner's Guide](https://nginx.org/en/docs/beginners_guide.html)
- [NGINX OSS](https://nginx.org/en/docs/)
- [NGINX Admin Guide](https://docs.nginx.com/nginx/admin-guide/security-controls/terminating-ssl-http/)
- [NGINX Configuring HTTPS](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [NGINX Blog / Webinar - HTTPS](https://www.nginx.com/blog/back-to-basics-web-traffic-encryption-with-ssl-tls-and-nginx/)
- [NIGNX Directives](https://nginx.org/en/docs/dirindex.html)
- [NGINX Variables](https://nginx.org/en/docs/varindex.html)
- [NGINX Logging](https://docs.nginx.com/nginx/admin-guide/monitoring/logging/)


<br/>

### Authors
- Chris Akker - Solutions Architect - Community and Alliances @ F5, Inc.
- Shouvik Dutta - Solutions Architect - Community and Alliances @ F5, Inc.

-------------

Navigate to ([Lab4](../lab4/readme.md) | [Main Menu](../LabGuide.md))