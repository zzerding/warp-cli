# warp-cli
warp-cli in docker. warp-cli proxy can only listen to 127.0.0.1. So the docker network mode can only be host.

## how to use
1. docker run  test
```shell
docker run -d \
  --name warp \
  --restart always \
  --network host \
  --env-file .env \
  --network host \
  zzerding/warp-cli
```

2. test this container(40000 is defalut port)
`curl -x socks5://127.0.0.1:40000 https://www.cloudflare.com/cdn-cgi/trace/`

3. change .env file use warp plus and change port

4. example docker compose
```yml
version: '3'
services:
  warp:
    image: zzerding/warp-cli
    container_name: warp
    restart: always
    network_mode: host
    env_file: .env
```

