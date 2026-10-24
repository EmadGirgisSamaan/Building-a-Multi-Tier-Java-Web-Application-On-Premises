#!/bin/bash
# db01 - MariaDB (CentOS Stream 9)
# Vagrant shell provisioner بيشغّل السكريبت كـ root، فمفيش حاجة لـ sudo

DATABASE_PASS='admin123'

dnf update -y
dnf install epel-release -y
dnf install git mariadb-server -y

systemctl enable --now mariadb

# بديل mysql_secure_installation (غير تفاعلي)
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DATABASE_PASS}';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
CREATE DATABASE IF NOT EXISTS accounts;
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY '${DATABASE_PASS}';
FLUSH PRIVILEGES;
EOF

# تحميل الكود واستيراد بيانات القاعدة
cd /tmp
rm -rf vprofile-project
git clone -b main https://github.com/hkhcoder/vprofile-project.git
mysql -u root -p"${DATABASE_PASS}" accounts < vprofile-project/src/main/resources/db_backup.sql

systemctl restart mariadb

# الفايروول
systemctl enable --now firewalld
firewall-cmd --zone=public --add-port=3306/tcp --permanent
firewall-cmd --reload

echo "db01 provisioning finished."
