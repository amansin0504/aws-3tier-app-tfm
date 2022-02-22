#!/bin/bash
sudo yum install -y epel-release yum-utils
sudo yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum-config-manager --enable remi-php73
sudo yum install -y php php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysqlnd
sudo yum install -y wget
sudo yum install -y unzip
sudo yum install -y lsof
sudo yum install -y httpd
sudo yum install -y ipset
sudo systemctl start httpd
sudo systemctl enable httpd

sudo setsebool -P httpd_can_network_connect 1

sudo wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cd wordpress
sudo cp wp-config-sample.php wp-config.php

sudo sed -i -E 's/username_here/${user}/g' ./wp-config.php
sudo sed -i -E 's/password_here/${password}/g' ./wp-config.php
sudo sed -i -E 's/database_name_here/${database}/g' ./wp-config.php
sudo sed -i -E 's/localhost/${host}/g' ./wp-config.php

sudo rsync -avP * /var/www/html/
sudo chown -R apache:apache /var/www/html/*
sudo systemctl restart httpd