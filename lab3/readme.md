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

    It should look something like this:

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

1. Let's check it with your browser.  This example is from Chrome, they will differ slightly for other browsers.

    Open Chrome, and then using the 3-dot menu, select More Tools, then Developer Tools.  Now type http://cars.example.com in the address bar.  You should see Chrome Dev Tools record and display the 301 redirect, if you click on the first URL Name:

    ![Chrome Redirect](media/lab3_chrome-redirect.png)

    *NOTE:  Like cURL, Chrome built-in security features also refuse to display content from web servers using Self Signed certificates - until you Refresh, and then click Advanced and Proceed to bypass these warnings.*

### NGINX TLS Settings

In this exercise, you will add some additional NGINX TLS settings to control the TLS protocol.  This will show you the flexibility in supporting both Modern and Legacy TLS / SSL protocols for a variety of HTTP clients.  It is considered a Best Practice to always use the Highest version of Protocol and Highest strength encryption Ciphers at all times.  However, given the vast variety of HTTP clients, you may have to "downgrade" your NGINX web server TLS configurations to accomodate less secure environments.  Always consult security experts with TLS experience for advice, as older protocols and ciphers can expose your webserver to Common Vulnerabilities and Exploits (CVEs).

>CAUTION:  TLS/SSL Security is a serious topic, and should only be used by those familar with the products, terminology, and concepts.  
>>NONE of the examples in this lab should ever be used in Production or Public facing websites, without verification and the approval from Security Professionals.

1. You will start by adding a High Security TLS configuration to your cars.example.com website.  You will configure and use the following components:

    - 4K TLS key length, 4096 bit
    - High Security Encryption Ciphers, Hashes, and other settings
    - TLS version 1.3

1. Inspect the /etc/ssl/dhparam/ folder. The 4096/dhparam.pem file contains the TLS Prime at 4,096 bits.  (And the 2048/dhparam.pem file sets the TLS Prime to 2,048 bits).  You will be using the 4,096 bit Prime for maximum security.  Normally you would create these Prime files yourself, but as they take some time to create, these files have been provided for you here.  See the References section for Links to more information on TLS/dhparams.

1. Inspect the `/nginx/includes/ssl_strong.conf` file.  Notice you are using TLS version 1.3, and very high strength ciphers, rated `A+` by SSL Labs, a third party TLS testing and information website.  You notice there are also 4 HTTP Headers being added, to help with additional security settings.

1. Docker Exec into your `nginx-oss` Container, and using VI, edit your `tls-cars.example.com.conf` as shown, just add one line for the `include` directive on line #18:

    ```nginx
    # cars.example.com HTTPS
    # NGINX Basics Workshop
    # Jan 2024, Chris Akker, Shouvik Dutta
    #
    server {
        
        listen 443 ssl;   # change to port 443, add "ssl" parameter for terminating TLS on all IP addresses on this machine

        server_name cars.example.com;   # Set hostname to match in request

    # Add the following 2 lines for NGINX cert and key directives and file locations

        ssl_certificate /etc/ssl/nginx/cars.example.com.crt;
        ssl_certificate_key /etc/ssl/nginx/cars.example.com.key;

    >>> ### Add the following for Strong TLS Security ###

        include /etc/nginx/includes/ssl/ssl_strong.conf;

    ...snip

    ```

    Save your file and reload NGINX.

1. Test with curl.  First, let's see if the new HTTP Headers are added:

    ```bash
    curl -kI https://cars.example.com

    ```

    Should look something like this, you should see 4 new HTTP Headers added to the Response:

    ```bash
    #Sample output
    HTTP/1.1 200 OK
    Server: nginx/1.25.3
    Date: Thu, 08 Feb 2024 00:01:25 GMT
    Content-Type: text/html
    Content-Length: 57
    Connection: keep-alive
    Strict-Transport-Security: max-age=63072000; includeSubDomains; preload   # Yes, 4 new Headers
    X-Frame-Options: DENY
    X-Content-Type-Options: nosniff
    X-XSS-Protection: 1; mode=block

    ```

    Next, try curl again, but this time add `-vv` for Verbose output, and it will show the TLS Handshake metadata.  Note the TLS Version and Cipher settings being used.

    ```bash
    curl -kI -vv https://cars.example.com

    ```

    Should look something like this,  # Comments added

    ```bash
    #Sample output
    *   Trying [::1]:443...
    * Connected to cars.example.com (::1) port 443 (#0)
    * ALPN: offers h2,http/1.1
    * (304) (OUT), TLS handshake, Client hello (1):
    * (304) (IN), TLS handshake, Server hello (2):
    * (304) (OUT), TLS handshake, Client hello (1):
    * (304) (IN), TLS handshake, Server hello (2):
    * (304) (IN), TLS handshake, Unknown (8):
    * (304) (IN), TLS handshake, Certificate (11):
    * (304) (IN), TLS handshake, CERT verify (15):
    * (304) (IN), TLS handshake, Finished (20):
    * (304) (OUT), TLS handshake, Finished (20):
    * SSL connection using TLSv1.3 / AEAD-AES256-GCM-SHA384         # TLSv1.3, Cipher
    * ALPN: server accepted http/1.1
    * Server certificate:
    *  subject: CN=NginxBasics                                   
    *  start date: Feb  6 23:08:20 2024 GMT
    *  expire date: Feb  5 23:08:20 2025 GMT
    *  issuer: CN=NginxBasics
    *  SSL certificate verify result: self signed certificate (18), continuing anyway.  # Self Signed
    * using HTTP/1.1
    > HEAD / HTTP/1.1
    > Host: cars.example.com
    > User-Agent: curl/8.1.2
    > Accept: */*
    >

    ```

    Now try it again, but this time set the Max TLS version to 1.2, which is older and less secure:

    ```bash
    curl -kI -v --tls-max 1.2 https://cars.example.com

    ```

    Should look something like this,  # Comments added

    ```bash
    #Sample output
    *   Trying [::1]:443...
    * Connected to cars.example.com (::1) port 443 (#0)
    * ALPN: offers h2,http/1.1
    * (304) (OUT), TLS handshake, Client hello (1):
    * LibreSSL/3.3.6: error:1404B42E:SSL routines:ST_CONNECT:tlsv1 alert protocol version  # Version mismatch error
    * Closing connection 0       # NGINX closes the connection immediately
    curl: (35) LibreSSL/3.3.6: error:1404B42E:SSL routines:ST_CONNECT:tlsv1 alert protocol version

    ```

1. Try with openssl, using its built-in `s_client` SSL client feature.  After all, it is Security, two sources are better than one, right ?

    ```bash
    openssl s_client cars.example.com:443

    ```

    ```bash
    #Sample output,                                      # Comments Added
    CONNECTED(00000006)
    depth=0 CN = NginxBasics
    verify error:num=18:self-signed certificate          # Here's our Self Signed Cert
    verify return:1
    depth=0 CN = NginxBasics
    verify return:1
    ---
    Certificate chain
    0 s:CN = NginxBasics
    i:CN = NginxBasics
    a:PKEY: rsaEncryption, 2048 (bit); sigalg: RSA-SHA256
    v:NotBefore: Feb  6 23:08:20 2024 GMT; NotAfter: Feb  5 23:08:20 2025 GMT
    ---
    Server certificate
    -----BEGIN CERTIFICATE-----
    MIIDDTCCAfWgAwIBAgIUPQE5kNK6wbnXQcT5Ksv6FOamWDQwDQYJKoZIhvcNAQEL
    BQAwFjEUMBIGA1UEAwwLTmdpbnhCYXNpY3MwHhcNMjQwMjA2MjMwODIwWhcNMjUw
    MjA1MjMwODIwWjAWMRQwEgYDVQQDDAtOZ2lueEJhc2ljczCCASIwDQYJKoZIhvcN
    AQEBBQADggEPADCCAQoCggEBAPA+UGG3bwoo30OHaOGvQStbiiFnuc3wm/SDYnzR
    gCaYB5nRJ+2qZMOEc989sFWxw4Drq93Z+m+9mMUQnjInONrf/qA+UOAvYYK9jBsN
    wjFxZeMGIDOqXvp7I4tCf+dpxAD5rsMyUXXiU9ksjzNaUOFWLtCmfUQ9mgxTcKnS
    NBt2LkNrAp6u72DQdbUyS+BAoOGEhj69rUuQfDLr7qpctjZ3mTzfIncbnnYzrXKW
    u+Vh2tmZJAk0EAk+IcvcrYjCysH+Kn50Invf4NigHD9+yxT9t7DHhiB9/2xw93BJ
    cyH+kc2N+w6ijgV994UXUzkSs5Q2X//oBHtkr3Xoi8rk95sCAwEAAaNTMFEwHQYD
    VR0OBBYEFDepAa0rVUhD/uHYJKm1/8rDVHqNMB8GA1UdIwQYMBaAFDepAa0rVUhD
    /uHYJKm1/8rDVHqNMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEB
    ALAP4dpXOBht9O4aSMFAwkD3j7pupGZYjo/UXnsdQhv8rCAEBouHcTnlpkd2YB4x
    VcPgm8P02C+uKqu93WRXeD49kvxh33pdwsp922X0ekfjb1sQ9yOnsGEZPYRbyFVp
    bs+KSo/J+HerPDirX3xX8oQQ+CtAGpfzSK7Pp7vT6L1rxHyors8bTUfpzxyR8zoP
    OSnfmZD9aIYfL/Qm9zN1X1YKKIZpWWMtKqMGzAQEDk/PKwdxfBnSzd5WeNKZze2t
    VlM1vlSf04fUV/jATaYWVUDO5kA89Hj0Brde3OsFDTczsaRAoJb+FEqTXoQH0zKs
    uMBDBpsCnwqjtB27MguwbAk=
    -----END CERTIFICATE-----
    subject=CN = NginxBasics
    issuer=CN = NginxBasics
    ---
    No client certificate CA names sent
    Peer signing digest: SHA256
    Peer signature type: RSA-PSS
    Server Temp Key: ECDH, secp384r1, 384 bits
    ---
    SSL handshake has read 1503 bytes and written 781 bytes
    Verification error: self-signed certificate
    ---
    New, TLSv1.3, Cipher is TLS_AES_256_GCM_SHA384                    # TLS Version and Cipher
    Server public key is 2048 bit
    This TLS version forbids renegotiation.
    Compression: NONE
    Expansion: NONE
    No ALPN negotiated
    Early data was not sent
    Verify return code: 18 (self-signed certificate)
    ---
    ---
    Post-Handshake New Session Ticket arrived:
    SSL-Session:
        Protocol  : TLSv1.3                                          # Session TLS Version and Cipher
        Cipher    : TLS_AES_256_GCM_SHA384
        Session-ID: DA3908C086B9930AFAB543538D1658188A94E8FEFA394CC8C2C0FE13740D63A9
        Session-ID-ctx:
        Resumption PSK: FB16F5F833A191CB184B162B82D2B07E1BEA491D7D153FEFF9748272CD424D40A6CF8A27B3CF37355883CA69E8A5F3F7
        PSK identity: None
        PSK identity hint: None
        SRP username: None
        TLS session ticket lifetime hint: 600 (seconds)
        TLS session ticket:
        0000 - 79 db ac 04 8a 2e b2 59-d6 18 b6 d4 2c 62 d2 0e   y......Y....,b..
        0010 - 38 74 e8 7c 26 e4 d0 ec-fb a7 ee 56 1f f1 ea 6f   8t.|&......V...o

        Start Time: 1707352054
        Timeout   : 7200 (sec)
        Verify return code: 18 (self-signed certificate)
        Extended master secret: no
        Max Early Data: 0
    ---
    read R BLOCK
    ---
    Post-Handshake New Session Ticket arrived:
    SSL-Session:                                                   # Session TLS Version and Cipher
        Protocol  : TLSv1.3
        Cipher    : TLS_AES_256_GCM_SHA384
        Session-ID: 1C2FB400E5C083A72F0A89FD193C0DC3D3F56A1378168611E7598260E030D53F
        Session-ID-ctx:
        Resumption PSK: 21B18DAC31528E7494B569588353909DEA0FE18893E98368DE51E7003EB04C8D86129670E2939B034F2A00BA7201262D
        PSK identity: None
        PSK identity hint: None
        SRP username: None
        TLS session ticket lifetime hint: 600 (seconds)
        TLS session ticket:
        0000 - 5e 5d 84 c8 74 cb 6c 18-24 dc 6e d8 b3 4e 6d d8   ^]..t.l.$.n..Nm.
        0010 - 40 7b 4b fd 3f 1d d7 39-9b 31 61 00 d9 4b 59 45   @{K.?..9.1a..KYE

        Start Time: 1707352054
        Timeout   : 7200 (sec)
        Verify return code: 18 (self-signed certificate)
        Extended master secret: no
        Max Early Data: 0
    ---
    read R BLOCK
    closed

    ```

1. Try with openssl, again with `TLS version set to 1.2`.  What do you expect ?

    ```bash
    openssl s_client --tls1_2 cars.example.com:443

    ```

    Should look something like this:

    ```bash
    #Sample output, Comments added
    CONNECTED(00000006)
    80973A4FF87F0000:error:0A00042E:SSL routines:ssl3_read_bytes:tlsv1 alert protocol version:ssl/record/rec_layer_s3.c:1586:SSL alert number 70    # Openssl Alert = 70, protocol_version mismatch error 
    ---
    no peer certificate available                     # No cert is even sent to the client
    ---
    No client certificate CA names sent
    ---
    SSL handshake has read 7 bytes and written 213 bytes
    Verification: OK
    ---
    New, (NONE), Cipher is (NONE)
    Secure Renegotiation IS NOT supported
    Compression: NONE
    Expansion: NONE
    No ALPN negotiated
    SSL-Session:
        Protocol  : TLSv1.2
        Cipher    : 0000
        Session-ID:
        Session-ID-ctx:
        Master-Key:
        PSK identity: None
        PSK identity hint: None
        SRP username: None
        Start Time: 1707352533
        Timeout   : 7200 (sec)
        Verify return code: 0 (ok)
        Extended master secret: no
    ---

    ```

As you can see, using the `ssl_strong.conf` file, with only TLS v1.3 enabled, will make any lower TLS version handshake FAIL.  If you like, try a couple other TLS versions, like 1.1 or 1.0 - you should expect the same results.




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