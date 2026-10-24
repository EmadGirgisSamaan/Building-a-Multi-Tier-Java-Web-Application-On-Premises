#!/bin/bash
# app01 - Tomcat 9 + build/deploy لتطبيق vprofile (CentOS Stream 9)
# تنبيه: أول build بياخد وقت لأن maven بينزّل dependencies كتير

TOMCAT_VERSION=9.0.75
TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"

# ضمان تعرّف الأسماء حتى لو hostmanager لسه ما حدّثش /etc/hosts
add_host() { grep -qw "$2" /etc/hosts || echo "$1 $2" >> /etc/hosts; }
add_host 192.168.56.15 db01
add_host 192.168.56.14 mc01
add_host 192.168.56.13 rmq01

dnf update -y
dnf install epel-release -y
dnf -y install java-11-openjdk java-11-openjdk-devel
dnf install git maven wget -y

# تحميل Tomcat
cd /tmp
wget -q "${TOMCAT_URL}" -O tomcat.tar.gz
tar xzf tomcat.tar.gz

# مستخدم tomcat ومجلده
id tomcat &>/dev/null || useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat
mkdir -p /usr/local/tomcat
cp -r /tmp/apache-tomcat-${TOMCAT_VERSION}/* /usr/local/tomcat/
chown -R tomcat:tomcat /usr/local/tomcat

# service file
cat > /etc/systemd/system/tomcat.service <<'EOF'
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
WorkingDirectory=/usr/local/tomcat
Environment=JRE_HOME=/usr/lib/jvm/jre
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINE_BASE=/usr/local/tomcat
ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh
SyslogIdentifier=tomcat-%i

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now tomcat

# الفايروول
systemctl enable --now firewalld
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --reload

# تحميل الكود وبناؤه
cd /tmp
rm -rf vprofile-project
git clone -b main https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
mvn install -B -ntp

# النشر
systemctl stop tomcat
rm -rf /usr/local/tomcat/webapps/ROOT*
cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
chown -R tomcat:tomcat /usr/local/tomcat/webapps
systemctl start tomcat

# مسح Java 17 (الحزمتين دول بس) بعد ما كل حاجة خلصت
# rpm -e --nodeps: يمسح الحزمتين بس من غير ما يمسح maven أو غيره معاهم
rpm -e --nodeps java-17-openjdk java-17-openjdk-headless || true

echo "Java بعد التنظيف:"
java -version 2>&1 | head -1

echo "app01 provisioning finished."
