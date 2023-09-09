# Docker Container Atsumeru

### Prerequisities

In order to run this container you'll need [docker](https://docs.docker.com/engine/install/) installed.

* [linux/amd64,linux/arm64/v8,linux/arm/v7](https://hub.docker.com/r/atsumerudev/atsumeru)

### Usage
#
#### Docker run

```shell
docker run -d \
    --name=atsumeru \
    -p 31337:31337 \
    -v /path/to/your/library:/library \
    -v /path/to/atsumeru/config:/app/config \
    -v /path/to/atsumeru/db:/app/database \
    -v /path/to/atsumeru/cache:/app/cache \
    -v /path/to/atsumeru/logs:/app/logs \
    --restart unless-stopped \
    atsumerudev/atsumeru:latest
```

#
#### Or another way, Docker-compose

```shell
curl https://raw.githubusercontent.com/OlegEnot/atsu-docker/master/example-docker-compose.yml --output docker-compose.yml
```
#### ```ATTENTION!``` Fix directories in ```docker-compose.yml``` file, after:

```shell
docker-compose up
```
#
#### Look at the Administrator's password for authorization on the server through the [application](https://github.com/AtsumeruDev/AtsumeruManager).
#### And don't forget to change it!

```shell
docker logs atsumeru
```
#
#### Volumes

* `/path/to/you/library:/library` - Path to your library files.
* `/path/to/atsumeru/db:/app/database` - Directory where server will store its databases.
* `/path/to/atsumeru/logs:/app/logs` - Directory where server will store its logs (optional).
* `/path/to/atsumeru/config:/app/config` - Directory where server will store its configuration files.
* `/path/to/atsumeru/cache:/app/cache` - Directory where server will store its covers cache.

#

## Running a private Atsumeru instance with Let's Encrypt certs

This example assumes that you have [installed](https://docs.docker.com/compose/install/) Docker Compose, that you have a domain name (e.g., `atsumeru.example.com`) for your atsumeru instance, and that it will be publicly accessible.

[Docker Compose](https://docs.docker.com/compose/) is a tool that allows the definition and configuration of multi-container applications. In our case, we want both the atsumeru server and a proxy to redirect the WebSocket requests to the correct place.

Docker Compose might be run as `docker-compose <command> ...` (with a dash) or `docker compose <command> ...` (with a space), depending on how you have installed Docker Compose. `docker-compose` is the original syntax, when Docker Compose was distributed as a standalone executable. You can still choose to do a [standalone](https://docs.docker.com/compose/install/other/#install-compose-standalone) installation, in which case you would continue to use this syntax. However, Docker currently recommends installing Docker Compose as a Docker plugin, where `compose` becomes a subcommand of `docker`, making the syntax `docker compose <command> ...`.

Start by making a new directory and changing into it. Next, create the `docker-compose.yml` below, making sure to substitute appropriate values for the `DOMAIN` and `EMAIL` variables.

```yaml
version: '3.3'

networks:
  atsumeru-net:
    driver: bridge

services:
    atsumeru:
        volumes:
            - '/path/to/you/library:/library'
            - '/path/to/atsumeru/config:/app/config'
            - '/path/to/atsumeru/db:/app/database'
            - '/path/to/atsumeru/cache:/app/cache'
            - '/path/to/atsumeru/logs:/app/logs'
        restart: unless-stopped
        image: 'atsumerudev/atsumeru:latest'
        networks:
            - atsumeru-net
    caddy:
        image: caddy:latest
        restart: unless-stopped
        ports:
            - "80:80"
            - "443:443"
            - "443:443/udp"
        volumes:
            - '/path/to/you/Caddyfile:/etc/caddy/Caddyfile:ro'
        networks:
            - atsumeru-net
        environment:
            DOMAIN: "https://atsumeru.example.com"     # Your domain.
            EMAIL: "admin@example.com"                 # The email address to use for ACME registration.
        depends_on:
            - atsumeru
```

In the same directory, create the `Caddyfile` below. (This file does not need to be modified.)
```
{$DOMAIN}:443 {
  tls {$EMAIL}
  reverse_proxy atsumeru:31337 {
       header_up X-Forwarded-For {remote_host}
  }
}
```

Run
```bash
docker compose up -d  # or `docker-compose up -d` if using standalone Docker Compose
```
to create and start the containers. A private network for the services in this `docker-compose.yml` file will be created automatically, with only Caddy being publicly exposed.

```bash
docker compose down  # or `docker-compose down` if using standalone Docker Compose
```
stops and destroys the containers.
#

## Cloudflare Tunnel

[Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) provides you with a secure way to connect your resources to Cloudflare without a publicly routable IP address.

To set up a Cloudflare Tunnel for your app, you can follow the instructions in this guide: Creating a Tunnel through the Cloudflare Dashboard. Navigate to `one.dash.cloudflare.com > Access > Tunnels` and click the "Create" button.

When prompted, specify the hostname as http://atsumeru:31337. The web refers to the service named web in our `docker-compose.yml` file.

![Tunnel config](https://i.imgur.com/scX67ID.jpeg)

Once the tunnel is created, click the "Configure" button and scroll down to find the Tunnel token. Copy this token as you will need it in the next step.

Now that you've created the tunnel, set up on your server side. Create a `docker-compose.yml` file and add your token:

```yaml
version: '3.3'

networks:
  atsumeru-net:
    driver: bridge

services:
    atsumeru:
        volumes:
            - '/path/to/you/library:/library'
            - '/path/to/atsumeru/config:/app/config'
            - '/path/to/atsumeru/db:/app/database'
            - '/path/to/atsumeru/cache:/app/cache'
            - '/path/to/atsumeru/logs:/app/logs'
        restart: unless-stopped
        image: 'atsumerudev/atsumeru:latest'
        networks:
            - atsumeru-net

    cloudflare-tunnel:
        image: cloudflare/cloudflared
        restart: unless-stopped
        command: 'tunnel --no-autoupdate run --token'
        volumes:
            - /etc/localtime:/etc/localtime:ro
        networks:
            - atsumeru-net
        environment:
            TUNNEL_TOKEN: "<token>"
        depends_on:
            - atsumeru
```

## Caddy with DNS challenge

Two DNS providers are covered:
* [Duck DNS](https://www.duckdns.org/) -- This gives you a subdomain under `duckdns.org` (e.g., `my-atsumeru.duckdns.org`). This option is simplest if you don't already own a domain.
* [Cloudflare](https://www.cloudflare.com/) -- This lets you put your atsumeru instance under a domain you own or control. Note that Cloudflare can be used as just a DNS provider (i.e., without the proxying functionality that Cloudflare is best known for).

## Duck DNS setup

Start by making a new directory and changing into it. Next, create the `docker-compose.yml` below, making sure to substitute appropriate values for the `DOMAIN` and `EMAIL` variables.

```yaml
version: '3.3'

networks:
  atsumeru-net:
    driver: bridge

services:
    atsumeru:
        volumes:
            - '/path/to/you/library:/library'
            - '/path/to/atsumeru/config:/app/config'
            - '/path/to/atsumeru/db:/app/database'
            - '/path/to/atsumeru/cache:/app/cache'
            - '/path/to/atsumeru/logs:/app/logs'
        restart: unless-stopped
        image: 'atsumerudev/atsumeru:latest'
        networks:
            - atsumeru-net
    caddy:
        image: caddy:latest
        restart: unless-stopped
        ports:
            - "80:80"
            - "443:443"
            - "443:443/udp"
        volumes:
            - '/path/to/you/binary/caddy:/usr/bin/caddy'  # Your custom build of Caddy.
            - '/path/to/you/Caddyfile:/etc/caddy/Caddyfile:ro'
        networks:
            - atsumeru-net
        environment:
            DOMAIN: "https://atsumeru.duckdns.org"     # Your domain.
            EMAIL: "admin@example.com"                 # The email address to use for ACME registration.
            DUCKDNS_TOKEN: "<token>"                   # Your Duck DNS token.
        depends_on:
            - atsumeru
```

The stock Caddy builds (including the one in the Docker image) don't include the DNS challenge modules, so next you'll need to [download Caddy custom build](https://caddyserver.com/download), search for `duckdns`. Rename the custom build as `caddy` and move it under the same directory as `docker-compose.yml`. Make sure the `caddy` file is executable (e.g., `chmod a+x caddy`). The `docker-compose.yml` file above bind-mounts the custom build into the `caddy:2` container, replacing the stock build.

If you don't already have an account, create one at https://www.duckdns.org/. Create a subdomain for your atsumeru instance (e.g., `my-atsumeru.duckdns.org`) and set its IP to your atsumeru host's private IP (e.g., `192.168.1.100`). Make note of your account's token (a string in [UUID](https://en.wikipedia.org/wiki/UUID) format). Caddy will need this token to solve the DNS challenge.

In the same directory, create the `Caddyfile` below. (This file does not need to be modified.)
```
{$DOMAIN}:443 {

  tls {
    dns duckdns {$DUCKDNS_TOKEN}
  }

  reverse_proxy atsumeru:31337 {
    header_up X-Forwarded-For {remote_host}
  }
}
```

## Cloudflare setup

If you don't already have an account, create one at https://www.cloudflare.com/; you'll also have to go to your domain registrar to set your nameservers to the ones assigned to you by Cloudflare. Create a subdomain for your atsumeru instance (e.g., `atsumeru.example.com`), setting its IP to your atsumeru host's private IP (e.g., `192.168.1.100`). For example:

![A record config](https://i.imgur.com/BBvy4Yj.png)

Create an API token for the DNS challenge (for more background, see https://github.com/libdns/cloudflare/blob/master/README.md):

1. In the upper right, click the person icon and navigate to `My Profile`, and then select the `API Tokens` tab.
1. Click the `Create Token` button, and then `Use template` on `Edit zone DNS`.
1. Edit the `Token name` field if you prefer a more descriptive name.
1. Under `Permissions`, the `Zone / DNS / Edit` permission should already be populated. Add another permission: `Zone / Zone / Read`.
1. Under `Zone Resources`, set `Include / Specific zone / example.com` (replacing `example.com` with your domain).
1. Under `TTL`, set an End Date for when your token will become inactive. You might want to choose one far in the future.
1. Create the token and copy the token value.

Your token list should look like:

![API token config](https://i.imgur.com/FoOv9Ww.png)

Create a file named `Caddyfile` with the following content:
```
{$DOMAIN}:443 {
  tls {$EMAIL}
  reverse_proxy atsumeru:31337 {
       header_up X-Forwarded-For {remote_host}
  }
}
```

**Important:** If necessary, in some routers an exception must be set for the domain (e.g., `atsumeru.example.com`) due to DNS rebind protection.

The stock Caddy builds (including the one in the Docker image) don't include the DNS challenge modules, so next you'll need to [download Caddy custom build](https://caddyserver.com/download), search for `cloudflare`. Rename the custom build as `caddy` and move it under the same directory as `docker-compose.yml`. Make sure the `caddy` file is executable (e.g., `chmod a+x caddy`). The `docker-compose.yml` file above bind-mounts the custom build into the `caddy:2` container, replacing the stock build.

```yaml
version: '3.3'

networks:
  atsumeru-net:
    driver: bridge

services:
    atsumeru:
        volumes:
            - '/path/to/you/library:/library'
            - '/path/to/atsumeru/config:/app/config'
            - '/path/to/atsumeru/db:/app/database'
            - '/path/to/atsumeru/cache:/app/cache'
            - '/path/to/atsumeru/logs:/app/logs'
        restart: unless-stopped
        image: 'atsumerudev/atsumeru:latest'
        networks:
            - atsumeru-net
    caddy:
        image: caddy:latest
        restart: unless-stopped
        ports:
            - "80:80"
            - "443:443"
            - "443:443/udp"
        volumes:
            - '/path/to/you/binary/caddy:/usr/bin/caddy'  # Your custom build of Caddy.
            - '/path/to/you/Caddyfile:/etc/caddy/Caddyfile:ro'
        networks:
            - atsumeru-net
        environment:
            DOMAIN: "https://atsumeru.example.com"     # Your domain.
            CLOUDFLARE_API_TOKEN: "<token>"            # Your cloudflare token.
        depends_on:
            - atsumeru
```

As with the HTTP challenge example, run to create and start the containers.
```bash
docker compose up -d  # or `docker-compose up -d` if using standalone Docker Compose
```

You should now be able to reach your atsumeru instance at https://atsumeru.example.com.
#
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
