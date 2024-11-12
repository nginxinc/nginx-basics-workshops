# Useful docker-compose commands

```bash
# List running containers
docker ps

# Start a bash session on a container
docker exec -i -t <CONTAINER ID> /bin/bash

# Stop services only
# The docker-compose stop command will stop your containers, but it won’t remove them.
docker compose stop

# Stop and remove containers, networks..
# The docker-compose down command will stop your containers, but it also removes the stopped containers as well as any networks that were created.
docker compose down

# Down and remove volumes
docker compose down --volumes

# Down and remove images
docker compose down --rmi <all|local>

# Kill running containers
docker compose kill

# Kill running containers and remove stopped service containers
docker compose kill && docker compose rm -f

# Restart a single container
docker compose restart <service name>
docker compose restart -t 30 <service name> #Specify a shutdown timeout in seconds

# Rebuild containers after making nginx config changes
docker compose up -d --force-recreate

# Rebuild containers after making Dockerfile changes
# This will first rebuild your images from any changed code. This is fast if 
# there are no changes since the cache is reused. Then Docker Compose will
# replaces the changed containers
docker compose up -d --build

# If your downloaded images are stale, you can precede the above command with `docker-compose pull`:
docker compose pull
docker compose up -d --build

## Kill and remove everything
# Stop all running containers
docker stop $(docker ps -aq)
# Remove all containers
docker rm $(docker ps -aq)
# Remove all images
docker rmi $(docker images -q)

## Clean way to rebuild compose stack ##
# Note that `docker-compose up` never rebuilds an image, so if you need to
# rebuild your stack you can do so with the following commands:
docker compose kill && docker compose rm -f
docker compose pull
docker compose build --no-cache
docker compose up -d --force-recreate

# Tail docker-compose logs
docker compose logs -f
```
