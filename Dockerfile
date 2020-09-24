#
# PHP Dockerfile
# version 1.1
#
FROM 192.168.1.202/base-repos/ubuntu:v3
MAINTAINER Leo <jiangwenhua@yoyohr.com>

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" \
        apt-get install -y php7.0-fpm \
        php7.0-bcmath \
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
    && cd /etc/php/7.0/fpm \
    && cat /proc/meminfo | grep Huge \
    && sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 20M/g' \
        php.ini \
    && sed -i 's/post_max_size = 8M/post_max_size = 25M/g' \
        php.ini \
    && sed -i 's/;opcache.file_cache=/opcache.file_cache=\/tmp/g' \
        php.ini \
    && sed -i 's/;opcache.huge_code_pages=1/opcache.huge_code_pages=1/g' \
        php.ini \
    && sed -i 's/memory_limit = 128M/memory_limit = 512M/g' \
        php.ini \
#    && sed -i 's/pm = dynamic/pm = static/g' \
#        pool.d/www.conf \
    && sed -i 's/pm.max_children = 5/pm.max_children = 1000/g' \
        pool.d/www.conf \
    && sed -i 's/;pm.max_requests = 500/pm.max_requests = 50000/g' \
        pool.d/www.conf \
    && { \
        echo '[global]'; \
        echo 'error_log = /proc/self/fd/2'; \
        echo; \
        echo '[www]'; \
        echo '; if we send this to /proc/self/fd/1, it never appears'; \
        echo 'access.log = /proc/self/fd/2'; \
        echo; \
        echo 'clear_env = no'; \
        echo; \
        echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
        echo 'catch_workers_output = yes'; \
    } | tee pool.d/docker.conf \
    && { \
        echo '[global]'; \
        echo 'daemonize = no'; \
        echo; \
        echo '[www]'; \
        echo 'listen = 9000'; \
    } | tee pool.d/zz-docker.conf; \
        \
    php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" \
        && php composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer \
        && php -r "unlink('composer-setup.php');" \
        && composer --version \
        && php -v

WORKDIR /var/www/html

EXPOSE 9000
CMD ["php-fpm7.0"]
