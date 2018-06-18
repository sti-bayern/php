# Use Alpine Linux
FROM alpine:latest

# Maintainer
MAINTAINER Günther Morhart


ENV TIMEZONE            Europa/Berlin
ENV PHP_MEMORY_LIMIT    512M
ENV MAX_UPLOAD          50M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST        100M

# Let's roll
RUN	apk update && \
	apk upgrade && \
	apk add --update tzdata && \
	echo "${TIMEZONE}" > /etc/timezone && \
	apk add --update \
		php5-bcmath \
		php5-bz2 \
		php5-ctype \
		php5-curl \
		php5-dom \
		php5-fpm \
		php5-gd \
		php5-gettext \
		php5-gmp \
		php5-iconv \
		php5-json \
                php5-ldap \
		php5-mcrypt \
		php5-mssql \
		php5-mysql \
		php5-odbc \
		php5-openssl \
		php5-pdo \
		php5-pdo_dblib \
		php5-pdo_mysql \
		php5-pdo_odbc \
		php5-pdo_pgsql \
		php5-pdo_sqlite \
		php5-pgsql \
		php5-soap \
		php5-sqlite3 \
		php5-xmlreader \
		php5-xmlrpc \
		php5-zip \
		php5-zlib && \

#
# wkhtmltopdf
#
    apk add --no-cache \
            xvfb \
            # Additionnal dependencies for better rendering
            ttf-freefont \
            fontconfig \
            dbus \
    && \

    # Install wkhtmltopdf from `testing` repository
    apk add qt5-qtbase-dev \
            wkhtmltopdf \
            --no-cache \
            --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
            --allow-untrusted \
    && \

    # Wrapper for xvfb
    mv /usr/bin/wkhtmltopdf /usr/bin/wkhtmltopdf-origin && \
    echo $'#!/usr/bin/env sh\n\
Xvfb :0 -screen 0 1024x768x24 -ac +extension GLX +render -noreset & \n\
DISPLAY=:0.0 wkhtmltopdf-origin $@ \n\
killall Xvfb\
' > /usr/bin/wkhtmltopdf && \
    chmod +x /usr/bin/wkhtmltopdf && \
		

# Set environments
sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php5/php-fpm.conf && \
sed -i "s|;*listen\s*=\s*127.0.0.1:9000|listen = 9000|g" /etc/php5/php-fpm.conf && \
sed -i "s|;*listen\s*=\s*/||g" /etc/php5/php-fpm.conf && \
sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php5/php.ini && \
sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php5/php.ini && \
sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|i" /etc/php5/php.ini && \
sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php5/php.ini && \
sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php5/php.ini && \
sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= 0|i" /etc/php5/php.ini && \

# Cleaning up
mkdir /www && \
apk del tzdata && \
rm -rf /var/cache/apk/*

# Set Workdir
WORKDIR /www

# Expose volumes
VOLUME ["/www"]

# Expose ports
EXPOSE 9000

# Entry point
ENTRYPOINT ["/usr/bin/php-fpm5"]
