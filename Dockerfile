FROM akilli/base

# Maintainer
MAINTAINER STI Bayern

# Let's roll
# ------------------------------------------------------
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
            php5-intl \
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
            php5-zlib
# ------------------------------------------------------

# wkhtmltopdf
# ------------------------------------------------------
RUN apk add --no-cache \
            xvfb \
            # Additionnal dependencies for better rendering
            ttf-freefont ttf-dejavu ttf-droid ttf-freefont ttf-liberation ttf-ubuntu-font-family \
            fontconfig \
            dbus
# Install wkhtmltopdf from `testing` repository
RUN apk add qt5-qtbase-dev \
            libgcc libstdc++ libx11 glib libxrender libxext libintl \
            libcrypto1.0 libssl1.0 \
            wkhtmltopdf \
            --no-cache \
            --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
            --allow-untrusted
# Wrapper for xvfb
RUN mv /usr/bin/wkhtmltopdf /usr/bin/wkhtmltopdf-origin && \
    echo $'#!/usr/bin/env sh\n\
Xvfb :0 -screen 0 1024x768x24 -ac +extension GLX +render -noreset & \n\
DISPLAY=:0.0 wkhtmltopdf-origin $@ \n\
killall Xvfb\
' > /usr/bin/wkhtmltopdf && \
    chmod +x /usr/bin/wkhtmltopdf
# ------------------------------------------------------

# PHP
# ------------------------------------------------------
# Set environments
RUN	sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php5/php-fpm.conf && \
    sed -i "s|;*listen\s*=\s*127.0.0.1:9000|listen = 9000|g" /etc/php5/php-fpm.conf && \
    sed -i "s|;*listen\s*=\s*/||g" /etc/php5/php-fpm.conf
COPY php.ini /etc/php5/conf.d/90-php.ini
COPY php-fpm.conf /etc/php5/php-fpm.conf
COPY www.conf /etc/php5/fpm.d/www.conf
# ------------------------------------------------------

# Cleaning up
# ------------------------------------------------------
RUN apk del tzdata && \
    rm -rf /var/cache/apk/*
# ------------------------------------------------------

# Expose ports
# ------------------------------------------------------
EXPOSE 9000

# Entry point
# ------------------------------------------------------
CMD ["php-fpm5", "-FO"]
#ENTRYPOINT ["/usr/bin/php-fpm5"]
