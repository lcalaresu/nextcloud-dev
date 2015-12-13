#!/bin/sh

touch /var/log/nginx/access.log
touch /var/log/nginx/error.log
touch /var/log/cron/owncloud.log

if [ -z "$SSL_CERT" ]
then
    echo "Copying nginx.conf without SSL support …"
    cp /root/nginx.conf /etc/nginx/nginx.conf
else
    echo "Copying nginx.conf with SSL support …"
    sed "s#-x-replace-cert-x-#$SSL_CERT#;s#-x-replace-key-x-#$SSL_KEY#;s#-x-server-name-x-#$OWNCLOUD_SERVERNAME#" /root/nginx_ssl.conf > /etc/nginx/nginx.conf
fi

if [ "$SQL" = "mysql" ]
then
	cp /root/autoconfig_mysql.php /var/www/owncloud/config/autoconfig.php
fi

if [ "$SQL" = "pgsql" ]
then
	cp /root/autoconfig_pgsql.php /var/www/owncloud/config/autoconfig.php
fi

if [ "$SQL" = "oci" ]
then
	cp /root/autoconfig_oci.php /var/www/owncloud/config/autoconfig.php
fi

chown -R www-data:www-data /var/www/html/data /var/www/html/config

echo "Starting server using $SQL database…"

tail --follow --retry /var/log/nginx/*.log /var/log/cron/owncloud.log &

/usr/sbin/cron -f &
/usr/bin/redis-server &
/usr/local/bin/apache2-foreground
