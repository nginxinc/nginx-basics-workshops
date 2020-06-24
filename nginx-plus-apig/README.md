# Deploying NGINX Plus as an API Gateway

This demo package is based on the techical blog post **Deploying NGINX Plus as an API Gateway** ([Part 1](https://www.nginx.com/blog/deploying-nginx-plus-as-an-api-gateway-part-1/), [Part 2](https://www.nginx.com/blog/deploying-nginx-plus-as-an-api-gateway-part-2-protecting-backend-services/))

## File Structure

To achieve this separation, we create a configuration layout that supports a multi‑purpose NGINX Plus instance and provides a convenient structure for automating configuration deployment through CI/CD pipelines. The resulting directory structure under `/etc/nginx` looks like this:

```
etc/
├── nginx/
│    ├── api_conf.d/ ………………………………………………… Subdirectory for per-API configuration
│    │   └── warehouse_api.conf …………………………… Definition and policy of the Warehouse API
│    │   └── warehouse_api_apikeys.conf ……… API key authenication
│    │   └── warehouse_api_bodysize.conf …… Enforce client request body size
│    │   └── warehouse_api_jwt.conf ………………… JWT Validation
│    │   └── warehouse_api_methods.conf ……… Enforce HTTP Methods
│    │   └── warehouse_api_precise.conf ……… Precise API endpoint definitions
│    │   └── warehouse_api_rewrites.conf …… Rewrite rules for API endpoints
│    │   └── warehouse_api_simple.conf ………… Broad and simple API endpoint definitions
│    ├── conf.d/……………………………………………………………… Subdirectory for other HTTP configurations (Web │server, load balancing, etc.)
│    │   └── demo_instructions.conf ………………… Demo Instructions on port 8000
│    │   └── echo_json.conf ……………………………………… Dummy API Servers - static json responses
│    │   └── health_checks.conf …………………………… Example active health check probes
│    │   └── status_api.conf …………………………………… NGINX Plus live activity monitoring API on port │8080
│    │   └── status_stub.conf ………………………………… NGINX OSS simple live metrics
│    ├── jwk/………………………………………………………………………… JSON Web Keys used to validate JWT
│    ├── jwt/………………………………………………………………………… JSON Web Tokens used to demo JWT validation
│    ├── api_backends.conf ………………………………………… The backend services (upstreams)
│    ├── api_keys.conf …………………………………………………… API keys
│    ├── api_gateway.conf …………………………………………… Top-level configuration for the API gateway server
│    ├── api_json_errors.conf ………………………………… HTTP error responses in JSON format
│    ├── api_jwt.conf ……………………………………………………… Global settings for JWT validation
│    ├── json_validator.js ………………………………………… NGINX javascript for json validation
│    └── nginx.conf …………………………………………………………… Main NGINX configuration file
└── ssl/
    ├── certs/ ………………………………………………………………… api.example.com self signed cert for HTTPS testing
    ├── jwt_key_cert/ ……………………………………………… Self signed certs used to generate the JWT and JWK
    ├── nginx/ ………………………………………………………………… NGINX Plus repo.crt and repo.key goes here
    └── private/ …………………………………………………………… Private key used for HTTPS testing

```

The directories and filenames for all API gateway configuration are prefixed with api_. Each of these files and directories enables different features and capabilities of the API gateway and illustrated in the demos

## Just add Nginx Plus License file

In order to build the Docker Container and run Nginx Plus you need to copy your Nginx Plus license or [Evaluation Trial License](https://www.nginx.com/thank-you-free-trial/#free-trial) (`nginx-repo.key` and `nginx-repo.crt`) into the `/etc/ssl/nginx/` directory, where Dockerfile will look

## Build Docker container

1. Build an image from your Dockerfile:

```bash
# Run command from the folder containing the `Dockerfile`
$ docker build -t nginx-plus-api-gateway .
# If you made changes to the Dockerfile and need to rebuild you probably need to use--no-cache
$ docker build -t nginx-plus-api-gateway . --no-cache
```

2. Start the Nginx Plus container, e.g.:

```bash
# Start a new container with the name, "nginx-plus-api-gateway"
# and publish container ports 80 (HTTP), 443 (HTTPS), 8000 (Demo instructions) and 8080 (NGINX Plus Dashboard) to the host
$ docker run -d --name nginx-plus-api-gateway -p 80:80 -p 443:443 -p 8080:8080 -p 8000:8000 nginx-plus-api-gateway
```

## Demo Instructions:

In one terminal view the Nginx logs in realtime and in another terminal enter the Nginx terminal. Open the demo instructions and NGINX Plus Dashboard in two seperate tabs in a web browser

### View Nginx logs in real time
```bash
# By CONTAINER ID
# docker logs -f [CONTAINER ID]

# By CONTAINER Name
$ docker logs -f nginx-plus-api-gateway
```

### Enter terminal of NGINX docker container
```bash
# By CONTAINER ID
# docker logs -f [CONTAINER ID]
# docker exec -i -t [CONTAINER ID] /bin/sh

# By CONTAINER Name
docker exec -i -t nginx-plus-api-gateway /bin/sh
```

### Nginx Live Monitoring Dashboard:

Open `http://localhost:8080`

### Read demo instructions:

Open `http://localhost:8000`

## Troubleshooting

### Useful Docker commands

```bash
# Find [CONTAINER ID] by running
$ docker ps -l

# See real time logging of docker container
$ docker logs -f [CONTAINER ID]

# stop container:
$ docker kill [CONTAINER ID]

# remove container:
$ docker rm [CONTAINER ID]

# remove image:
$ docker rm [IMAGE ID]

# -------------------

# stop all containers:
$ docker kill $(docker ps -q)

# remove all containers
$ docker rm $(docker ps -a -q)

# remove all docker images
$ docker rmi $(docker images -q)

# -------------------

# rebuild container from modified Dockerfile with --no-cache option:
$ docker build -t nginx-plus-api-gateway . --no-cache

# -------------------

# view container logs
docker logs -f [CONTAINER ID] #by ID
```

### 403 Forbidden

If you get a `403 Forbidden` error when loading the page, adjust the following file permissons on the HTML page:

```bash
# Enter terminal of NGINX docker container:
$ sudo docker exec -i -t [CONTAINER ID] /bin/sh

# From the docker container terminal:
$ chown -R nginx:nginx /etc/nginx
```