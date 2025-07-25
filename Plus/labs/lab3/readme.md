# NGINX Plus with TLS

## Introduction

In this Lab, NGINX with HTTPS TLS termination will be introduced.  HTTPS is commonly used to secure a website with encryption, so that data sent between the browser and the NGINX server cannot be easily read like clear text HTTP. You will explore common TLS configuration directives and variables, to provide encryption for your traffic.  You will also explore some common tools to create and test TLS encryption components.

## Learning Objectives

By the end of the lab you will be able to:

- Create a Self-signed TLS certificate and key
- Configure NGINX to use a TLS cert and key
- Configure TLS settings
- Add some TLS Best Practice configurations
- Test and validate TLS traffic components and settings

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

## Create a TLS Self-signed Certificate and Key

In this exercise, you will use `openssl` to create a Self-signed certificate and key to use for these exercises.  However, it should be clearly understood, that Self-signed certificates are exactly that - they are created and signed by you or someone else.  `They are not signed by any official Certificate Authority`, so they are not recommended for any use other than testing in local lab exercises.  Most Modern Internet Browsers will display Security Warnings when they receive a Self-Signed certificate from a webserver.  In some environments, the Browser may actually block access completely.  So use Self-signed certificates with `CAUTION`.

<br/>

![Openssl](media/openssl-logo.png)

<br/>

1. >NOTE:  Make sure you ran `docker compose down` from the lab2 folder, before starting Lab3!

1. Ensure you are in the `lab3` folder.  Using a Terminal, use Docker Compose to build and run the `nginx-plus` container.  This is a new image, based on the Dockerfile in the lab3 folder.  The `openssl` libraries have been added, so you can use them to build, configure, and test TLS.  Optionally, you can use `openssl` if it is installed on your local machine.

1. Run Docker Compose to build and run your containers:

   ```bash
    cd lab3
    docker compose up --force-recreate -d

   ```

1. After the Docker Compose has completed, and the lab3/nginx-plus container is running, Docker Exec into the nginx-plus container.

    ```bash
    docker exec -it nginx-plus /bin/bash

    ```

1. Change to the /etc/ssl folder, and create a new folder called nginx:

    ```bash
    cd /etc/ssl
    mkdir -p nginx

    ```

1. Change directory to this new nginx folder.  Using openssl, create a new self-signed TLS certificate and key files.  You will be using these to provide TLS for your `cars.example.com` website:

    ```bash
    cd nginx
    ```

    ```bash
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout cars.example.com.key -out cars.example.com.crt -subj "/CN=NginxPlusBasics"

    ```

    Quick explanation of the `openssl` command above:

    - Create a new x509 compatible certificate and key files
    - Expiration is one year, 365 days
    - Use 2048 bit RSA encryption
    - Use TLS Common Name "NginxPlusBasics"
    - Name the files `cars.example.com.crt`, and `cars.example.com.key`

1. Verify the files were created, list them in the folder, and use `cat` to look at them:

    ```bash
    ls -l

    ```

    ```bash
    ##Sample output##
    total 8
    -rw-r--r--    1 root     root          1119 Feb  5 19:40 cars.example.com.crt
    -rw-------    1 root     root          1708 Feb  5 19:40 cars.example.com.key

    ```

    ```bash
    cat cars.example.com.crt

    ```

    ```bash
    ##Sample output##
    -----BEGIN CERTIFICATE-----
    MIIDDTCCAfWgAwIBAgIUdPfXtRGjRfM9H72saPaB0iFxfukwDQYJKoZIhvcNAQEL
    ...snip
    FEW+0L1jGJzuvVtP0LwIywc=
    -----END CERTIFICATE-----

    ```

    ```bash
    cat cars.example.com.key

    ```

    ```bash
    ##Sample output##
    -----BEGIN PRIVATE KEY-----
    MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDc8eIOHsfGOop1
    ...snip
    SHa8zigyl3iYJAenhMSat74Rng==
    -----END PRIVATE KEY-----

    ```

<br/>

## NGINX Plus with TLS

<br/>

NGINX Plus | TLS
:----:|:----:
![NGINX](media/nginx-plus-icon.png) | ![Padlock](media/padlock-icon.png)

<br/>

Now that you have a TLS cert and key for testing, you will configure NGINX to use them.

*NOTE:*  If you have a real TLS cert and key issued by a Certificate Authority, you can use those files in this exercise if you like, just copy them to the docker container, and use the configuration commands below.

1. In the `labs/lab3/nginx-plus/etc/nginx/conf.d` folder, make the following changes to your `tls-cars.example.com.conf` file:

    1. On line #1, change the comment from HTTP to HTTPS
    2. On line #6-7, comment out the `listen 81` directive and uncomment the `listen 443 ssl`, to enable port 443 and ssl.
    3. On line #13-14, uncomment the `ssl_certificate` and `ssl_certificate_key` directives.

1. Your updated `tls-cars.example.com.conf` should look similar to this:

    ```nginx
    # cars.example.com HTTPS                # updated comment
    # NGINX Plus Basics Workshop
    # Nov 2024, Chris Akker, Shouvik Dutta
    #
    server {
        
        # listen 81;   # Use port 81 to avoid conflicts
        listen 443 ssl;   # Uncomment to change to port 443, add "ssl" parameter for terminating TLS on all IP addresses on this machine

        server_name cars.example.com;   # Set hostname to match in request

        # Uncomment the following 2 lines for NGINX cert and key directives and file locations.  The filenames and path must be correct.

        ssl_certificate /etc/ssl/nginx/cars.example.com.crt;
        ssl_certificate_key /etc/ssl/nginx/cars.example.com.key; 

    ...snip

    ```

1. Once the content of the file has been saved, Docker Exec into the nginx-plus container.

   ```bash
    docker exec -it nginx-plus bin/bash

   ```

1. Test and reload your NGINX config by running `nginx -t` and `nginx -s reload` commands respectively from within the container.

1. Now give it a try with curl, using a Terminal on your local machine.

    ```bash
    # Run curl from outside of container
    curl https://cars.example.com

    ```

    ```bash
    ##Sample output##

    curl: (60) SSL certificate problem: self signed certificate
    More details here: https://curl.haxx.se/docs/sslcerts.html
    
    curl failed to verify the legitimacy of the server and therefore could not establish a secure connection to it. To learn more about this situation and how to fix it, please visit the web page mentioned above.

    ```

    As you can see, `curl reports an error` that the certificate is not legitimate (because it is Self-singed) and refuses to complete the request!  Adding the `-k` switch means `-insecure`, which tells curl to ignore this error - this is required for Self-signed certificates.

    Give that a try:

    ```bash
    curl -k https://cars.example.com

    ```

    ```bash
    ##Sample output##
    Let's go fast, you have reached cars.example.com, path /

    ```

    > Congrats!  That was easy - you have just enabled TLS on your webserver with only 3 NGINX commands!

    1. Change the `listen` directive
    2. Add the ssl_certificate
    3. Add the ssl_certificate_key

1. Now try it with a browser, go to <https://cars.example.com>.  YIKES - what's this??  Most modern browsers will display an `Error or Security Warning`:

    ![Certificate Invalid](media/lab3_cert-invalid.png)

1. You can use Chrome's built-in Certificate Viewer to look at the details of the TLS certificate that was sent from NGINX to your browser.  In the address bar, click on the `Not Secure` icon, then `Cerificate is not valid`, and it will display the certificate.  Who provided this Invalid Certificate??  - well, you did.

    ![Certificate Details](media/lab3_cert-details.png)

1. With Chrome, Close the Certificate Viewer, and then you have to click on the Advanced button, and then the Proceed link, to bypass the Warning and continue.  

    >>CAUTION:  Ignoring Browser Warnings is **Dangerous**, only Ignore these warnings if you are 100% sure it is safe to proceed!!

1. After you safely Proceed, you should see the cars.example.com `Let's go fast` message.  

    ![Cars Proceed](media/lab3_cars-proceed.png)

1. Re-test all your cars.example.com URLs using HTTPS, ( /gtr, /nsx, /rcf, /browse ) they should all work the same as before, but now NGINX is using TLS to encrypt the traffic.

1. Test time!!  Does the /browse URL work as expected?  What are your observations?

    Click for Hint Here < rename the index.html file to index.html.bak, then try it.  You will find the /browse settings and details in the Optional Lab on Directory Browsing.>

### Enable HTTP > HTTPS redirect

Now that you have a working TLS configuration, you decide everyone should use it.  However, sometimes users forget to type the `S` with `http`, or saved the URL as an old bookmark, and come to your NGINX server with an HTTP request on port 80.  You will configure a helpful HTTP to HTTPS re-direct, to automagically send all users over to your HTTPS configuration.

1. Edit the file `cars.example.com.conf` within the same mounted folder(`labs/lab3/nginx-plus/etc/nginx/conf.d`).  In the `/` location block, uncomment the HTTP>HTTPS `return 301` directive on line #21, and also comment out the `return 200` directive on line #23.  This will enable any incoming requests to port 80, getting a friendly re-direct to port 443, like this:

    ```nginx
    location / {
        
        default_type text/html;

        # Uncomment for HTTP>HTTPS re-direct
        return 301 https://$host$request_uri;
        # Comment the line below
        # return 200 "Let's go fast, you have reached cars.example.com, path $uri\n";
    }

    ...snip

    ```

1. Once the content of the file has been saved, Docker Exec into the nginx-plus container.

   ```bash
    docker exec -it nginx-plus bin/bash

   ```

1. Test and reload your NGINX config by running `nginx -t` and `nginx -s reload` commands respectively from within the container.

1. Test out your redirect with curl, adding the `-I` parameter to show just the Headers:

    ```bash
    # Run curl from outside of container
    curl -I http://cars.example.com

    ```

    It should look something like this:

    ```bash
    ##Sample output##
    HTTP/1.1 301 Moved Permanently
    Server: nginx/1.25.4
    Date: Tue, 06 Feb 2024 23:22:06 GMT
    Content-Type: text/html
    Content-Length: 169
    Connection: keep-alive
    Location: https://cars.example.com/    # Notice the Schema, now HTTPS://

    ```

    Now let's follow the re-direct, with `-L`, and `-k` for insecure - does that work?

    ```bash
    curl -ILk http://cars.example.com
    ```

    It should look something like this:

    ```bash
    ##Sample output##

    HTTP/1.1 301 Moved Permanently
    Server: nginx/1.25.4
    Date: Wed, 07 Feb 2024 00:09:41 GMT
    Content-Type: text/html
    Content-Length: 169
    Connection: keep-alive
    Location: https://cars.example.com/    # Redirected to here

    HTTP/1.1 200 OK
    Server: nginx/1.25.4
    Date: Wed, 07 Feb 2024 00:09:41 GMT
    Content-Type: text/html
    Content-Length: 57
    Connection: keep-alive

    ```

1. Let's check it with your browser.  This example is from Chrome, it will differ slightly for other browsers.

    Open Chrome, and then using the 3-dot menu, select More Tools, then Developer Tools.  Now type <http://cars.example.com> in the address bar.  You should see Chrome Dev Tools record and display the 301 redirect, if you click on the first URL Name:

    ![Chrome Redirect](media/lab3_chrome-redirect.png)

    *NOTE:  Like cURL, Chrome built-in security features also refuse to display content from web servers using Self-signed certificates - until you Refresh, and then click Advanced and Proceed to bypass these warnings.*

<br/>

### NGINX TLS Settings

NGINX  | Openssl | TLS
:----:|:----:|:----:
![nginx icon](media/nginx-icon.png) | ![openssl icon](media/openssl-logo.png) | ![padlock icon](media/padlock-icon.png)

<br/>

In this exercise, you will add some additional NGINX TLS settings to control the TLS protocol.  This will show you the flexibility in supporting both Modern and Legacy TLS / SSL protocols for a variety of HTTP clients.  It is considered a Best Practice to always use the Highest version of Protocol and Highest strength encryption Ciphers at all times.  However, given the vast variety of HTTP clients, you may have to "downgrade" your NGINX web server TLS configurations to accomodate less secure environments.  Always consult security experts with TLS experience for advice, as older protocols and ciphers can expose your webserver to Common Vulnerabilities and Exploits (CVEs).

>CAUTION:  TLS/SSL Security is a serious topic, and should only be used by those familar with the products, terminology, and concepts.  
>>NONE of the examples in this lab should ever be used in Production or Public facing websites, without verification and the approval from Security Professionals.

1. You will start by adding a High Security TLS configuration to your cars.example.com website.  You will configure and use the following components:

    - 4K TLS key length, 4096 bit
    - High Security Encryption Ciphers, Hashes, and other settings
    - TLS version 1.3

1. Inspect the `labs/lab3/nginx-plus/etc/ssl/dhparam/` folder. The `dhparam-4096.pem` file contains the TLS Prime at 4,096 bits.  (And the `dhparam-2048.pem` file sets the TLS Prime to 2,048 bits).  You will be using the 4,096 bit Prime for maximum security.  Normally you would create these Prime files yourself, but as they take some time to create, these files have been provided for you here.  See the [References](#references) section for Links to more information on TLS/dhparams.

1. Inspect the `/labs/lab3/nginx-plus/etc/nginx/includes/ssl/ssl_strong.conf` file.  Notice you are using TLS version 1.3, and very high strength ciphers, rated `A+` by SSL Labs, a third party TLS testing and information website.  You notice there are also 4 HTTP Headers being added, to provide additional security settings.

1. Update your `tls-cars.example.com.conf` file within your mounted folder (`labs/lab3/nginx-plus/etc/nginx/conf.d`) as shown below, and uncomment the `ssl_strong.conf` for the `include` directives on line #18:

    ```nginx
    # cars.example.com HTTPS
    # NGINX Basics Workshop
    # Nov 2024, Chris Akker, Shouvik Dutta
    #
    server {
        
        listen 443 ssl;   # change to port 443, add "ssl" parameter for terminating TLS on all IP addresses on this machine

        server_name cars.example.com;   # Set hostname to match in request

    # Add the following 2 lines for NGINX cert and key directives and file locations

        ssl_certificate /etc/ssl/nginx/cars.example.com.crt;
        ssl_certificate_key /etc/ssl/nginx/cars.example.com.key;

    ### Uncomment one of the following for TLS Security Settings ###

    include /etc/nginx/includes/ssl/ssl_strong.conf;
    # include /etc/nginx/includes/ssl/ssl_modern.conf;
    # include /etc/nginx/includes/ssl/ssl_intermediate.conf;
    # include /etc/nginx/includes/ssl/ssl_old.conf;

    ...snip

    ```

1. Once the content of the file has been saved, Docker Exec into the nginx-plus container.

   ```bash
    docker exec -it nginx-plus bin/bash

   ```

1. Test and reload your NGINX config by running `nginx -t` and `nginx -s reload` commands respectively from within the container.

1. Test with curl.  First, let's see if the new HTTP Headers are added:

    ```bash
    curl -kI https://cars.example.com

    ```

    Should look something like this, you should see 4 new HTTP Headers added to the Response:

    ```bash
    ##Sample output##
    HTTP/1.1 200 OK
    Server: nginx/1.25.4
    Date: Thu, 08 Feb 2024 00:01:25 GMT
    Content-Type: text/html
    Content-Length: 57
    Connection: keep-alive
    # Yes, 4 new Headers added
    Strict-Transport-Security: max-age=63072000; includeSubDomains; preload   
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
    ##Sample output##
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
    *  subject: CN=NginxPlusBasics                                   
    *  start date: Feb  6 23:08:20 2024 GMT
    *  expire date: Feb  5 23:08:20 2025 GMT
    *  issuer: CN=NginxPlusBasics
    *  SSL certificate verify result: self signed certificate (18), continuing anyway.  # Self-signed
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
    ##Sample output##
    *   Trying [::1]:443...
    * Connected to cars.example.com (::1) port 443 (#0)
    * ALPN: offers h2,http/1.1
    * (304) (OUT), TLS handshake, Client hello (1):
    * LibreSSL/3.3.6: error:1404B42E:SSL routines:ST_CONNECT:tlsv1 alert protocol version         # Version mismatch error
    * Closing connection 0   # NGINX closes the connection immediately
    curl: (35) LibreSSL/3.3.6: error:1404B42E:SSL routines:ST_CONNECT:tlsv1 alert protocol version

    ```

    <details>
        <summary><b>Optional Exercise 1 </b></summary>

    <br/>

    Optional Exercise - Try with OpenSSL, using its built-in `s_client` SSL client feature.  After all, it is Security, two sources of info are better than one, right ?

    ```bash
    openssl s_client cars.example.com:443

    ```

    ```bash
    ##Sample output##,                             # Comments Added
    CONNECTED(00000006)
    depth=0 CN = NginxPlusBasics
    verify error:num=18:self-signed certificate    # Here's our Self-signed Cert
    verify return:1
    depth=0 CN = NginxPlusBasics
    verify return:1
    ---
    Certificate chain
    0 s:CN = NginxPlusBasics
    i:CN = NginxPlusBasics
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
    subject=CN = NginxPlusBasics
    issuer=CN = NginxPlusBasics
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
    </details>

1. Optional Exercise - Try with OpenSSL, again with `TLS version set to 1.2`.  What do you expect ?

    ```bash
    openssl s_client --tls1_2 cars.example.com:443

    ```

    Should look something like this:

    ```bash
    ##Sample output##, Comments added
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

    As you can see, using the `ssl_strong.conf` file, with only TLS v1.3 enabled, will make any lower TLS version handshake FAIL.  If you like, try a couple other TLS versions, like 1.1 or 1.0 - you should expect the same results.  But NOTE, older versions are no longer supported with some testing tools, so double-check that your SSL client even works with lower versions of TLS itself.

    However, we all live in a messy Internet world, and not all apps and clients are capable of running the latest and greatest software, so being able to handle older, less secure TLS traffic is likely a requirement that you will run into.  In this next exercise, we will downgrade the TLS parameters to "Medium" security settings, so your website will accomodate older versions of TLS, namely 1.1 and 1.2.

1. Inspect the `/includes/ssl/ssl_intermediate.conf` file, you will see that the TLS version is set to 1.0, 1.1, 1.2 on line #17 with the `ssl_protocols` directive.  You can modify this to meet your needs if you like.

1. Update your `tls-cars.example.com.conf` file within your mounted folder (`labs/lab3/nginx-plus/etc/nginx/conf.d`) and change the comments to use the `/includes/ssl/ssl_intermediate.conf`, instead of the `ssl_strong.conf`.

    ```nginx
    ...snip

    ### Uncomment one of the following for TLS Security Settings ###

        # include /etc/nginx/includes/ssl/ssl_strong.conf;
        # include /etc/nginx/includes/ssl/ssl_modern.conf;
        include /etc/nginx/includes/ssl/ssl_intermediate.conf;
        # include /etc/nginx/includes/ssl/ssl_old.conf;

    ...snip

    ```

1. Once the content of the file has been saved, Docker Exec into the nginx-plus container.

   ```bash
    docker exec -it nginx-plus bin/bash

   ```

1. Test and reload your NGINX config by running `nginx -t` and `nginx -s reload` commands respectively from within the container.

1. Check the HTTP Headers, what is different from `ssl_strong` ?

    ```bash
    curl -kI https://cars.example.com

    ```

    Should look something like this, you should see only 1 new HTTP Header added to the Response:

    ```bash
    ##Sample output##
    HTTP/1.1 200 OK
    Server: nginx/1.25.4
    Date: Thu, 08 Feb 2024 18:27:51 GMT
    Content-Type: text/html
    Content-Length: 57
    Connection: keep-alive
    Strict-Transport-Security: max-age=15768000      # Added a single HSTS Header

    ```

1. Test again using curl, will your website now accept TLS versions 1.2?

    ```bash
    curl -kI -v --tls-max 1.2 https://cars.example.com

    ```

    ```bash
    ##Sample output##
    *   Trying [::1]:443...
    * Connected to cars.example.com (::1) port 443 (#0)
    * ALPN: offers h2,http/1.1
    * (304) (OUT), TLS handshake, Client hello (1):
    * (304) (IN), TLS handshake, Server hello (2):
    * TLSv1.2 (IN), TLS handshake, Certificate (11):
    * TLSv1.2 (IN), TLS handshake, Server key exchange (12):
    * TLSv1.2 (IN), TLS handshake, Server finished (14):
    * TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
    * TLSv1.2 (OUT), TLS change cipher, Change cipher spec (1):
    * TLSv1.2 (OUT), TLS handshake, Finished (20):
    * TLSv1.2 (IN), TLS change cipher, Change cipher spec (1):
    * TLSv1.2 (IN), TLS handshake, Finished (20):
    * SSL connection using TLSv1.2 / ECDHE-RSA-CHACHA20-POLY1305      # Yes - TLS v1.2 now works
    * ALPN: server accepted http/1.1
    * Server certificate:
    *  subject: CN=NginxPlusBasics
    *  start date: Feb  6 23:08:20 2024 GMT
    *  expire date: Feb  5 23:08:20 2025 GMT
    *  issuer: CN=NginxPlusBasics
    *  SSL certificate verify result: self signed certificate (18), continuing anyway.  # Self-signed cert
    * using HTTP/1.1
    > HEAD / HTTP/1.1
    > Host: cars.example.com
    > User-Agent: curl/8.1.2
    > Accept: */*
    >
    < HTTP/1.1 200 OK
    HTTP/1.1 200 OK
    < Server: nginx/1.25.4
    Server: nginx/1.25.4
    < Date: Thu, 08 Feb 2024 18:32:07 GMT
    Date: Thu, 08 Feb 2024 18:32:07 GMT
    < Content-Type: text/html
    Content-Type: text/html
    < Content-Length: 57
    Content-Length: 57
    < Connection: keep-alive
    Connection: keep-alive
    < Strict-Transport-Security: max-age=15768000
    Strict-Transport-Security: max-age=15768000                    # One new HTTP Header added
    
    ```

    >NOTE:  For testing with versions below TLS 1.2, you will likely need to modify your local OpenSSL Client's openssl.cnf file security parameters, which is outside the scope of this exerices.  FYI - many modern OpenSSL clients do not support TLS versions below 1.2.  Curl and other tools may have also similar restrictions with older TLS versions.

    >>So after Peer Review, your Security team says **`Absolutely NOT!`** to any TLS version older that 1.2.  So after testing and auditing and compliance paperwork, you will use the `ssl_modern.conf` configuration file instead.  It is set for TLS 1.2, and will support most of the modern browsers and HTTP clients.

1. Inspect the `/labs/lab3/nginx-plus/etc/nginx/includes/ssl/ssl_modern.conf` file, to confirm it only contains the TLS protocols and ciphers that are approved by your Security team.

1. Update your `tls-cars.example.com.conf` file within your mounted folder (`labs/lab3/nginx-plus/etc/nginx/conf.d`) and change the comments to use the `/includes/ssl/ssl_modern.conf`.

    ```nginx
    ...snip

    ### Uncomment one of the following for TLS Security Settings ###

    # include /etc/nginx/includes/ssl/ssl_strong.conf;
    include /etc/nginx/includes/ssl/ssl_modern.conf;
    # include /etc/nginx/includes/ssl/ssl_intermediate.conf;
    # include /etc/nginx/includes/ssl/ssl_old.conf;

    ...snip

    ```

1. Once the content of the file has been saved, Docker Exec into the nginx-plus container.

   ```bash
    docker exec -it nginx-plus bin/bash

   ```

1. Test and reload your NGINX config by running `nginx -t` and `nginx -s reload` commands respectively from within the container.  

1. You should now re-test and verify that these Modern TLS parameters will work well for your environment, and pass muster with your Security team.

<br/>

### Optional Lab Exercise - NGINX with TLS Ciphers

Not all TLS Ciphers are the same, and not all Ciphers work with all versions of TLS.  They often go hand-in-hand, they must match correctly to work as expected.  In this exercise, you will test a couple different TLS Ciphers against your `Modern TLS Settings` from the previous exercise.

1. Try a cipher that you know works with TLS1.2, `ECDHE-ECDSA-AES256-GCM-SHA384`, which is found first in the list in your `labs/lab3/nginx-plus/etc/nginx/includes/ssl/ssl_modern.conf` file:

    ```bash
    curl -kI -v --tlsv1.2 --tls-max 1.2 -cipher ECDHE-ECDSA-AES256-GCM-SHA384 https://cars.example.com

    ```

    That should have been a successful test.

1. Next, try a TLS1.3 cipher, `ECDHE-RSA-AES256-GCM-SHA384`, which is found first in the list in your `labs/lab3/nginx-plus/etc/nginx/includes/ssl/ssl_strong.conf` file, which only uses TLS1.3:

    ```bash
    curl -kI -v --tlsv1.3 --tls-max 1.3 -cipher ECDHE-RSA-AES256-GCM-SHA512 https://cars.example.com

    ```

    Unfortunately, this should fail, because this Cipher will only work with TLS1.3, but your current NGINX TLS config is set for `Modern` with TLS1.2.

>CAUTION: Security Warning !!
>> It should also be noted, a very old SSL config file is provided for your review, `labs/lab3/nginx-plus/etc/nginx/includes/ssl/ssl_old.conf`, for clients older than TLS v1.0.  Hopefully you will never have to use these Legacy settings, but if you do, please consult with your Security team, perform extensive testing, and use other security measures before using it.

<br/>

### NGINX TLS/SSL Logging

In this next lab exercise, you will create a new NGINX Access Log format, and add some important `$ssl_` logging variables.  This will help you watch and understand what SSL paramenters are being used for the TLS handshake, SNI (Server Name Indication), ciphers, and other parameters.  This log format will extend the default `main` NGINX Access log format, and you will apply this to your TLS enabled website so you can see it working.

As a Best Practice, you should not modify the `main` log format, but rather copy this one and create a new one with your changes.  The `include` directive is also use here, because it makes your NGINX configurations more concise, uniform, and consistent.  As you will likely want to use the same access log format for multiple websites, you will define it ONCE, but use it for many server blocks, instead of duplicating the log format config for every website.  If you need to make a change to your log format, you can update it in one file, but it would apply to all your websites/server blocks.

1. Inspect the `main_ssl.conf` configuration file, located in the `/etc/nginx/includes/log_formats` folder.  Notice the 4 new `$ssl` variables added at the end - for the `TLS Version`, `Cipher`, `SNI`, and `Session_ID`.

    ```nginx
    # Extended SSL Log Format
    # Nginx Basics
    log_format  main_ssl    'remote_addr="$remote_addr", '
                                '[time_local=$time_local], '
                                'request="$request", '
                                'status="$status", '
                                'http_referer="$http_referer", '
                                'body_bytes_sent="$body_bytes_sent", '
                                'Host="$host", '
                                'sn="$server_name", '
                                'request_time=$request_time, '
                                'http_user_agent="$http_user_agent", '
                                'http_x_forwarded_for="$http_x_forwarded_for", '
                                'request_length="$request_length", ' 'ssl_ver="$ssl_protocol", ' 'ssl_cipher="$ssl_cipher", ' 'ssl_sname="$ssl_server_name", ' 'ssl_sess_id="$ssl_session_id", '  ;

    ```

1. Now you need to tell NGINX where to find these new log format definitions. Update your `nginx.conf`, to add your `etc/nginx/includes/log_formats` folder as a search location:

    ```nginx
    ...snip

        access_log  /var/log/nginx/access.log  main;

        # Uncomment for custom Access log formats
        include /etc/nginx/includes/log_formats/*.conf; # Custom Access logs formats found here

    ...snip

    ```

    Save your `nginx.conf` file.  

1. Next, modify your `tls-cars.example.com.conf` file to use this new log format. Change the log format from `main` to `main_ssl`:

    ```nginx
    ...snip

    # access_log  /var/log/nginx/cars.example.com.log main;
    access_log  /var/log/nginx/cars.example.com.log main_ssl;   # Change to SSL log format 

    ...snip

    ```

    Save your `tls-cars.example.com.conf` file.

1. Once the content of both the files have been saved, Docker Exec into the nginx-plus container.

   ```bash
    docker exec -it nginx-plus bin/bash

   ```

1. Test and reload your NGINX config by running `nginx -t` and `nginx -s reload` commands respectively from within the container. If all was correct, it will reload and now your cars.example.com website will be using a new access log format.  Let's go check.

1. Watch the `var/log/nginx/cars.example.com.log` log file, and watch as you send a couple requests.

    ```bash
    tail -f /var/log/nginx/cars.example.com.log

    ```

    It should look similar to this, comments and new lines added for clarity:

    ```bash
    ##Sample output##
    remote_addr="192.168.65.1", [time_local=12/Feb/2024:20:03:35 +0000], request="GET /browse/rcf.jpg HTTP/1.1", status="200", http_referer="https://cars.example.com/browse/rcf.html", body_bytes_sent="132435", Host="cars.example.com", sn="cars.example.com", request_time=0.000, http_user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36", http_x_forwarded_for="-", request_length="619", 

    # New SSL logging details
    ssl_ver="TLSv1.2", 
    ssl_cipher="ECDHE-RSA-AES256-GCM-SHA384", 
    ssl_sname="cars.example.com", ssl_sess_id="0d25f82bae148ce3b067f61bdae1b50eff21723e0616d3a8bf9ee0ba7a570ae3", 

    ```

    You should see the value in adding some SSL variables to your logs, especially at Audit time.

    Type Ctrl-C when you are finished tailing the log.

<br/>

## Wrap Up

>Don't forget - Save any Docker containers/images, docker compose, NGINX config files and Notes you may want for future reference.

>If you are finished with this lab, you can use Docker Compose to shut down your test environment. Make sure you are in the `lab3` folder:

```bash
cd lab3
docker compose down

```

```bash
##Sample output##
Running 2/2
Container nginx-plus          Removed                            
Network lab3_default          Removed

```

### Summary

In this lab, you learned the following NGINX / Docker topics.

- Create a Self-signed TLS certificate and key
- Configure NGINX to use a TLS cert and key
- Configure TLS settings
- Add some TLS Best Practice configurations
- Test and validate TLS traffic components and settings

<br/>

**This completes Lab3.**

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

- Chris Akker - Solutions Architect - Modern Apps Team @ F5, Inc.
- Shouvik Dutta - Solutions Architect - Modern Apps Team @ F5, Inc.
- Adam Currier - Solutions Architect - Modern Apps Team @ F5, Inc.

-------------

Navigate to ([Lab4](../lab4/readme.md) | [Main Menu](../readme.md))