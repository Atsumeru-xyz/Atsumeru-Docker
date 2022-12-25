# Docker Container Atsumeru

### Prerequisities

In order to run this container you'll need [docker](https://docs.docker.com/desktop/install/linux-install/) installed.

* [Linux-AMD64](https://hub.docker.com/repository/docker/olegenot/atsumeru)

### Usage

#### Container run

```shell
docker run -d --name=atsumeru -p 31337:31337 -v /path/to/you/library:/library -v /path/to/you/db:/app/database -v /path/to/you/logs:/app/logs --restart unless-stopped olegenot/atsumeru:latest
```
#### Look at the Administrator's password for authorization on the server through the [application](https://github.com/AtsumeruDev/AtsumeruManager).
#### And don't forget to change it!

```shell
docker logs atsumeru
```

#### Volumes

* `/path/to/you/library:/library` - storage location for your content files.
* `/path/to/you/db:/app/database` - storage location for the database directory.
* `/path/to/you/logs:/app/logs` - storage location for the logs directory (optional).

## Built With

* List the software v1.0.0
* That are in this container v0.0.1

## Find Us

* [GitHub](https://github.com/AtsumeruDev/Atsumeru)

## Versioning

For the versions available, see the 
[tags on this repository](https://hub.docker.com/repository/docker/olegenot/atsumeru/tags). 

## Acknowledgments

* [AtsumeruDev](https://t.me/atsumeru_app)