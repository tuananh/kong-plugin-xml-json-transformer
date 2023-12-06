FROM kong/kong-gateway:3.3-alpine
USER root
RUN apk update && \
    apk add lua5.1 lua5.1-dev luarocks5.1 && \
    apk add gcc expat expat-dev expat-static musl-dev
RUN luarocks install xml2lua 1.5-2
USER kong