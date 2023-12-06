#!/usr/bin/env bash
set -Eeuo pipefail

if [ ! "$(docker network ls | grep kong-net)" ]; then
  echo "Creating kong-net network ..."
  docker network create kong-net
else
  echo "kong-net network exists."
fi

if [ "$(docker ps -aq -f name=nginx-test)" ]; then
    echo "stop & remove nginx-test..."
    docker stop nginx-test
    docker rm nginx-test
fi

echo 'start a nginx instance to serve test xml'
docker run -d --name nginx-test \
    --network=kong-net \
    -v $(pwd)/test-upstream/test.xml:/usr/share/nginx/html/test.xml \
    -p 8080:8080 \
    cgr.dev/chainguard/nginx

if [ "$(docker ps -aq -f name=kong-apigw)" ]; then
    echo "stop & remove kong-apigw..."
    docker stop kong-apigw
    docker rm kong-apigw
fi

echo 'start kong apigw'
    docker run -d --name kong-apigw \
        --network=kong-net \
        --link nginx-test:nginx-test \
        --mount type=bind,source="$(pwd)"/kong/plugins/xml-json-transformer,destination=/usr/local/share/lua/5.1/kong/plugins/xml-json-transformer \
        --mount type=bind,source="$(pwd)"/kong/kong.yml,destination=/etc/kong/kong.yml \
        -e "KONG_LOG_LEVEL=debug" \
        -e "KONG_DATABASE=off" \
        -e "KONG_DECLARATIVE_CONFIG=/etc/kong/kong.yml" \
        -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
        -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
        -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
        -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
        -e "KONG_PROXY_LISTEN=0.0.0.0:8000, 0.0.0.0:8443 ssl http2" \
        -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl http2" \
        -e "KONG_ADMIN_GUI_LISTEN=0.0.0.0:8002, 0.0.0.0:10445 ssl" \
        -e "KONG_ADMIN_GUI_URL=http://localhost:8002" \
        -e "KONG_PLUGINS=bundled,xml-json-transformer" \
        -e "KONG_NGINX_WORKER_PROCESSES=2" \
        -e KONG_LICENSE_DATA \
        -p 8000:8000 \
        -p 8443:8443 \
        -p 8001:8001 \
        -p 8002:8002 \
        -p 8444:8444 \
        kong:local

echo 'docker logs kong-apigw -f'