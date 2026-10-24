#!/bin/bash
# mc01 - Memcached (CentOS Stream 9)

dnf update -y
dnf install epel-release -y
dnf install memcached -y

# السماح بالاتصال من خارج الجهاز بدل localhost فقط
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached

systemctl enable --now memcached
systemctl restart memcached

# الفايروول (TCP 11211 و UDP 11111)
systemctl enable --now firewalld
firewall-cmd --add-port=11211/tcp --permanent
firewall-cmd --add-port=11111/udp --permanent
firewall-cmd --reload

echo "mc01 provisioning finished."
