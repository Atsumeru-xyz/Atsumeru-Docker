# Docker Container Atsumeru

### Prerequisities

In order to run this container you'll need [docker](https://docs.docker.com/engine/install/) installed.

* [linux/amd64,linux/arm64/v8,linux/arm/v7](https://hub.docker.com/r/atsumerudev/atsumeru)

### Usage

#### Container run

```shell
docker run -d --name=atsumeru -p 31337:31337 -v /path/to/you/library:/library -v /path/to/atsumeru/config:/app/config -v /path/to/atsumeru/db:/app/database -v /path/to/atsumeru/cache:/app/cache -v /path/to/atsumeru/logs:/app/logs --restart unless-stopped atsumerudev/atsumeru:latest
```
#### Look at the Administrator's password for authorization on the server through the [application](https://github.com/AtsumeruDev/AtsumeruManager).
#### And don't forget to change it!

```shell
docker logs atsumeru
```

#### Volumes

* `/path/to/you/library:/library` - storage location for your content files.
* `/path/to/atsumeru/db:/app/database` - storage location for the database directory.
* `/path/to/atsumeru/logs:/app/logs` - storage location for the logs directory (optional).

## Manual assembly

```shell
curl https://raw.githubusercontent.com/OlegEnot/atsu-docker/master/Dockerfile --output Dockerfile
```

```shell
docker buildx create --name atsumeru --platform=linux/amd64,linux/arm64/v8,linux/arm/v7 --use
```

```shell
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 --builder=atsumeru -t atsumeru:latest .
```

## Built With

* List the software v1.0.2

## Find Us

* [GitHub](https://github.com/AtsumeruDev/Atsumeru)

## Versioning

For the versions available, see the 
[tags on this repository](https://hub.docker.com/r/atsumerudev/atsumeru/tags). 

## Acknowledgments

* [AtsumeruDev](https://t.me/atsumeru_app)
