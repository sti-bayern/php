FROM adbv/base

# Maintainer
MAINTAINER Günther Morhart

# Proxy
ARG proxy=""
ENV http_proxy=http://10.167.16.21:80
ENV https_proxy=http://10.167.16.21:80
ENV no_proxy="localhost, *.bvv.bayern.de, *.blva.bayern.de, *.lvg.bayern.de, *.bybn"

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
RUN	apk add --no-cache \
            xvfb \
            # Additionnal dependencies for better rendering
            ttf-freefont \
            fontconfig \
            dbus
# Install wkhtmltopdf from `testing` repository
RUN	apk add --no-cache \
            --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
            --allow-untrusted \
            qt5-qtbase-dev \
            wkhtmltopdf
# Wrapper for xvfb
COPY wkhtmltopdf /usr/bin/wkhtmltopdf
# ------------------------------------------------------

# PHP
# ------------------------------------------------------
# Set environments
RUN	sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php5/php-fpm.conf && \
    sed -i "s|;*listen\s*=\s*127.0.0.1:9000|listen = 9000|g" /etc/php5/php-fpm.conf && \
    sed -i "s|;*listen\s*=\s*/||g" /etc/php5/php-fpm.conf
COPY php.ini /etc/php5/conf.d/90-php.ini
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
