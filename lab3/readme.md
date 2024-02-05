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

In this exercise, you will use `openssl` to create a self-signed certificate and key to use for these exercises.  However, it should be clearly understood, that Self-Signed certificates are exactly that - they are created and signed by you or someone else.  `They are not signed by any official Certificate Management Entity`, so they are not recommended for any use other than local lab exercises.  Most Modern Internet Browsers will display Security Warnings when they receive a Self-Signed certificate from a Server.  In some environments, the Browser will block access entirely.  So use Self-Signed certificates with `CAUTION`.

1. Ensure you are in the `lab3` folder.  Using a Terminal, use Docker Compose to build and run the `nginx-oss` container.  This is a new image, based on the Dockerfile in the lab3 folder.  The `openssl` libraries have been added, so you can use them to build, configure, and test TLS.

1. After the Docker Compose has completed, and the lab3/nginx-oss container is running, Docker Exec into the nginx-oss container.

    ```bash
    docker exec -it < lab3 nginx-oss Container ID > /bin/bash

    ```

1. Change to the /etc/ssl folder, and create a new folder called nginx:

    ```bash
    cd /etc/ssl
    mkdir -p nginx

    ```

1. Change directory to this nginx folder.  Using openssl, create a new self-signed TLS certificate and key files.  You will be using these to provide TLS for your `cars.example.com` website:

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
    BQAwFjEUMBIGA1UEAwwLTmdpbnhCYXNpY3MwHhcNMjQwMjA1MTk0MDMyWhcNMjUw
    MjA0MTk0MDMyWjAWMRQwEgYDVQQDDAtOZ2lueEJhc2ljczCCASIwDQYJKoZIhvcN
    AQEBBQADggEPADCCAQoCggEBANzx4g4ex8Y6inUMfDZf+kmcJzQvy+i1iK4zG9eE
    QXMRcSVCkxto/nC5FE6V10vGHjgxlNO6TbwviH0cJgkmQwRmZsPHcm7ikeyFvSFb
    uL7F+6Sgks/81ktQJEJwn6VkKdUPsZbkn0oAycXOHuqrPzvTbaohjp24sHQ1GKDP
    F6ZvDAxlENYftMvH5zuWgUbPOFbYeUchTYdL7rPT1oQo5Iw0OXGvBxUbvl7XW0k/
    0ia9KPVRG0xwrxAad0pRHI4DfNZrW0bh8Ig7LA5YBIXArwJRYQOdxGZaeXUDB3RF
    dfFbLMVt1yVh4SdtRoYFXmZRjTZHv0tNYQjXjYb29LWabBMCAwEAAaNTMFEwHQYD
    VR0OBBYEFAee4uyOPkYzO0yyhYEfZGtepKsuMB8GA1UdIwQYMBaAFAee4uyOPkYz
    O0yyhYEfZGtepKsuMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEB
    AJf5p7rjN2x7ZCU1dO2T1M9SDxQ8xCMKGIti2BqAWfW4VIhN9iMA7EpDiVtByC70
    A1lKY/YsSxP6+r9wxh4AYBvWbIqfdNYfUovW8QMArLrfVDbFYTj40ahpfnIX5/Xy
    zy/Hz7a6ReM9NQPWDUimQY+3erw85KEhz/Z0x6I9rv5OlcpaHBnz/BnVgZbK99Wm
    1LhXWp4xHm2eaH6gaydrQhOl30I0sU9Iu2jgPsoykywZd2oy2CL3aCwIyCLqgHTc
    65zShPveWiVLMicUs2LuiU3WypUIpXPs66u5EJXFZVIZ3/PpP2VgpIlXVWMfpN6O
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
    DHw2X/pJnCc0L8votYiuMxvXhEFzEXElQpMbaP5wuRROlddLxh44MZTTuk28L4h9
    HCYJJkMEZmbDx3Ju4pHshb0hW7i+xfukoJLP/NZLUCRCcJ+lZCnVD7GW5J9KAMnF
    zh7qqz87022qIY6duLB0NRigzxembwwMZRDWH7TLx+c7loFGzzhW2HlHIU2HS+6z
    09aEKOSMNDlxrwcVG75e11tJP9ImvSj1URtMcK8QGndKURyOA3zWa1tG4fCIOywO
    WASFwK8CUWEDncRmWnl1Awd0RXXxWyzFbdclYeEnbUaGBV5mUY02R79LTWEI142G
    9vS1mmwTAgMBAAECggEAL7lfpsUnSb4jYh0MR4J7waKlJTSdyupLV7VacjbzHDPM
    SMwUknsfWqHfrQnYs1lb9a9gAkvftqJdzQhjft5w42ZrFCbkpObzti89JxN02GBT
    dr/odlyavTHWYzOIiGUWVBtLtNg1P/rjmoJnUzEiO33z1ifhclgOZUuCwll5Nk2n
    bf+33/em/9mK/HgrrDFVtO/+tYGncexUPDt/SDtxVF6/N7mkuWNUGVi4oC8YDQ1c
    J+fIeZwWApfSlLf5L9uJl+xAdRTCvxILLWPsA0rfe5RBvbOPObN28KUA8FYMt0B1
    Q6u5vct3LtXoVj9xUhecI3XU5xMNah9Sy6/bWwVQgQKBgQD3XwISb/b+3clAzCk2
    jsi8gLQbvsDoiE+Fqmgz6kIJ2ABwFJuO09E/eb3clrX6TYputJ01lisvO0gnLXdD
    okmpVOislFkfmQCzwqdBVw59OIp3vESN1MqMEMpCyiL0JyOGK1oTGx2LYDDN3rh2
    IUf0Wg8cHNIrSXRIOKHPhBlbsQKBgQDkpuRMT74/4o5CgHD6faGcouWVWX7nSERr
    Ml4wdWUNxu+nGoK3NKGP9EaGa8xRAoye0G/k0ZrKlEOSOADf8Ma/jPqJowhG2Lek
    8A5XRSQAoIy6g4JbJfLfWy5AMQ+uLmH1X9QC8hWo/w9+JfdXNOO5gD7aEZ6lahbd
    z1VhLk8pAwKBgQCvcZnVm8VxU7mWFHaydChY0WtsNik5gtvrsEWBdIbr1l/RHjyJ
    2x8QRvbqiZV9dhtVkxHg3KW6NPBioPNya5qU11zCceCX8Xs3Azp+tBDZrQ1ACK4S
    bbZOCuZ44kZSJaQjV4HmBRg6LrnOeUUYu1f+LRWEWciR3OH1Cv1wYX9esQKBgQCS
    iKImhbRXHMoutEGzRnAcAgk//WrmrdmrGUxjodhxS9yqKsM6xfAEYXgRDWSTRh74
    aHxNGEcrLHlha6Kj4Zp9h8vICUN0o86NVYrbQuQfwsRtg3o3D8rmeXjaipaR+get
    SQyGFr7q3wr+vTYWHT8T0qx09HXHbIXbANSmwxbYIQKBgQDoOdL6wetqagldWzAL
    /lo+dJvG65nUUijYZdbE5Qk5Y5l4CvI64ypJXiOgS07Ii2qDjyaVg4XlfLwGtTrP
    8DKq4rEpRdUst/ehjJA+ptxLr/mqmjAuHsfhimNDr+YDb2JkW7TqhAJ71nwVNqos
    SHa8zigyl3iYJAenhMSat74Rng==
    -----END PRIVATE KEY-----

    ```

1. Now that you a TLS cert and key, you can configure NGINX to use them.  Change to the `/etc/nginx/conf.d` folder, and make a copy of your existing cars.example.com.conf file.  You will edit this new file, to add and change NGINX parameters for TLS:

    ```bash
    cd /etc/nginx/conf.d
    cp cars.example.com.conf tls-cars.example.com.conf

    ```

1. Using VI, make the following changes to your tls-cars.example.com.conf file:

    - On line #1, change the comment from HTTP to HTTPS
    - On line #7, change the `listen 80` directive to `listen 443 ssl`.
    - Insert 2 new lines, between the server_name and access_log lines:
    - - ssl_certificate /etc/ssl/nginx/cars.example.com.crt;
    - - ssl_certificate_key /etc/ssl/nginx/cars.example.com.key;

1. Your updated `tls-cars.example.com.conf` should look similar to this:

    ```nginx
    # cars.example.com HTTPS                - updated comment
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

1. Now try it with a browser, go to https://cars.example.com.  YIKES - same thing!  Most modern browsers will display an `Error or Security Warning`:

    ![Certificate Invalid](media/lab3_cert-invalid.png)

1. You can use Chrome's built-in Certificate Viewer to look at the details of the TLS certificate that was sent from NGINX to your browser.  In the address bar, click on the `Not Secure` icon, then `Cerificate is not valid`, and it will display the certificate.

    ![Certificate Details](media/lab3_cert-details.png)


1. With Chrome, Close the Certificate Viewer, and then you have to click on the Advanced button, and then the Proceed link, to bypass the Warning and continue.  

    >CAUTION:  Ignoring Browser Warnings is **Dangerous**, only Ignore these warnings if you are sure it is safe to proceed!!

1. After you safely Proceed, you should see the cars.example.com `Let's go fast` message.  

    ![Cars Proceed](media/lab3_cars-proceed.png)

1. Re-test all your cars.example.com URLs using HTTPS, ( /gtr, /nsx, /rcf, /browse ) they should all work the same as before, but now NGINX is using TLS to encrypt the traffic.


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