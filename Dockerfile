ARG PHP_VERSION
FROM php:7.2.19-fpm-alpine

ARG TZ
ARG PHP_EXTENSIONS
ARG CONTAINER_PACKAGE_URL


COPY ./extensions /tmp/extensions
WORKDIR /tmp/extensions


RUN if [ "mirrors.aliyun.com" != "" ]; then \
        sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g" /etc/apk/repositories; \
    fi


RUN if [ "pdo_mysql,mysqli,mbstring,gd,curl,opcache,redis,swoole" != "" ]; then \
        apk add --no-cache autoconf g++ libtool make curl-dev linux-headers; \
    fi


RUN chmod +x install.sh && sh install.sh && rm -rf /tmp/extensions


RUN apk --no-cache add tzdata \
    && cp "/usr/share/zoneinfo/Asia/Shanghai" /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone


# Fix: https://github.com/docker-library/php/issues/240
RUN apk add gnu-libiconv --no-cache --repository http://mirrors.aliyun.com/alpine/edge/community/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php


WORKDIR /www
