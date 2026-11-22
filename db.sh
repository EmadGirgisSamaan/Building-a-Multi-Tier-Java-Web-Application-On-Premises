#!/bin/bash
# db01 - MariaDB (CentOS Stream 9)
# Vagrant shell provisioner

DATABASE_PASS='admin123'

dnf update -y
dnf install epel-release -y
dnf install git mariadb-server -y

systemctl enable --now mariadb

#  mysql_secure_installation 
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DATABASE_PASS}';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
CREATE DATABASE IF NOT EXISTS accounts;
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY '${DATABASE_PASS}';
FLUSH PRIVILEGES;
EOF

# import data to database
cd /tmp
rm -rf vprofile-project
git clone -b main https://github.com/hkhcoder/vprofile-project.git
mysql -u root -p"${DATABASE_PASS}" accounts < vprofile-project/src/main/resources/db_backup.sql

systemctl restart mariadb

# firewall
systemctl enable --now firewalld
firewall-cmd --zone=public --add-port=3306/tcp --permanent
firewall-cmd --reload

echo "db01 provisioning finished."
