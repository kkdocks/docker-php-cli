#
# PHP Dockerfile
# version 1.1
#
FROM registry.youpin-k8s.net/base-repos/ubuntu:v3
LABEL maintainer="nekoimi <nekoimime@gmail.com>"

USER root

RUN (id -u www > /dev/null 2>&1) && userdel www ; \
    echo 'done'

RUN groupadd -g 263 www \
    && useradd -s /sbin/nologin www -d /var/www/html -g www -u 263 \
    && apt-get update \
    && DEBIAN_FRONTEND="noninteractive" \
        apt-get install -y php7.0-bcmath \
        php7.0-curl \
        php7.0-gd \
        php7.0-intl \
        php7.0-json \
        php7.0-mbstring \
        php7.0-mcrypt \
        php7.0-mysql \
        php7.0-opcache \
        php7.0-soap \
        php7.0-xml \
        php7.0-zip \
        --no-install-recommends \
    && mkdir /run/php \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex \
        \
    php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" \
        && php composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer \
        && php -r "unlink('composer-setup.php');" \
        && composer --version

WORKDIR /var/www/html

CMD ["php", "-v"]
