#!/bin/bash
# rmq01 - RabbitMQ (CentOS Stream 9)

dnf update -y
dnf install epel-release -y
dnf install wget -y

dnf -y install centos-release-rabbitmq-38
dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server

systemctl enable --now rabbitmq-server

# Allowing the user to log in from outside the device
echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config

# Create the user test and make him administrator
rabbitmqctl add_user test test
rabbitmqctl set_user_tags test administrator

systemctl restart rabbitmq-server

# Firewall
systemctl enable --now firewalld
firewall-cmd --add-port=5672/tcp --permanent
firewall-cmd --reload

echo "rmq01 provisioning finished."
