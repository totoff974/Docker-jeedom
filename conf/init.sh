#!/bin/bash

set -e

su -
chmod 0644 /etc/cron.d/jeedom
chmod 0644 /etc/cron.d/jeedom_watchdog

echo 'Start cron'
/etc/init.d/cron restart

echo 'Start init'

echo "127.0.0.1 localhost jeedom" > /etc/hosts

if ! [ -f /.dockerinit ]; then
        touch /.dockerinit
        chmod 755 /.dockerinit
fi

if [ -f /var/www/html/core/config/common.config.php ]; then
        echo 'Jeedom is already install'
else
        echo 'Start jeedom installation'
        cp -R /srv/html/* /var/www/html
fi

if [ -d /var/lib/mysql/jeedom ]; then
        echo 'Jeedom is already install'
else
        echo 'mysql installation'
        cp -R /srv/mysql/* /var/lib/mysql
fi

if ! grep -q '$_interface = "eth0"' /var/www/html/core/class/network.class.php; then
   sed -i '/$_interface)/a\                if (preg_match_all("/eth/",$_interface,$out)) {\n                        $_interface = "eth0";\n                }' /var/www/html/core/class/network.class.php
fi


echo 'All init complete'
chmod 777 /dev/tty*
chmod 777 -R /tmp
chmod 755 -R /var/www/html
chmod 755 -R /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql
chown -R www-data:www-data /var/www/html


echo 'Start mysql'
service mysql restart

echo 'Start apache2'
service apache2 restart

echo 'Start sshd'
service ssh restart

/usr/bin/supervisord
