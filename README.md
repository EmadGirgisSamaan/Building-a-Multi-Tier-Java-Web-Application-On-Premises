# vprofile-vagrant

A 5-VM local environment for the **vprofile** Java web application, built with
Vagrant + VirtualBox and provisioned entirely with shell scripts. One
`vagrant up` creates every server and installs its service.

> The application source code is **not** part of this repo. It is cloned at
> provision time from [hkhcoder/vprofile-project](https://github.com/hkhcoder/vprofile-project).
> This repo contains only the infrastructure: the `Vagrantfile` and provisioning scripts.

## Architecture

```
Browser -> web01 (Nginx :80) -> app01 (Tomcat :8080) -> db01 (MariaDB :3306)
                                                    |-> mc01 (Memcached :11211)
                                                    '-> rmq01 (RabbitMQ :5672)
```

| VM    | Role                    | IP            | RAM  | OS                  | Script        |
|-------|-------------------------|---------------|------|---------------------|---------------|
| db01  | MariaDB                 | 192.168.56.15 | 2 GB | CentOS Stream 9     | `mysql.sh`    |
| mc01  | Memcached               | 192.168.56.14 | 1 GB | CentOS Stream 9     | `memcache.sh` |
| rmq01 | RabbitMQ                | 192.168.56.13 | 1 GB | CentOS Stream 9     | `rabbitmq.sh` |
| app01 | Tomcat 9 + Java 11      | 192.168.56.12 | 6 GB | CentOS Stream 9     | `tomcat.sh`   |
| web01 | Nginx reverse proxy     | 192.168.56.11 | 1 GB | Ubuntu 22.04        | `nginx.sh`    |

Total RAM: 11 GB, so a host with 16 GB or more is recommended.

## Requirements

- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)
- `vagrant-hostmanager` plugin (the Vagrantfile installs it automatically if missing)

## Usage

```bash
git clone https://github.com/EmadGirgisSamaan/Building-a-Multi-Tier-Java-Web-Application-On-Premises.git
cd Building-a-Multi-Tier-Java-Web-Application-On-Premises
vagrant up            # or one at a time: db01, mc01, rmq01, app01, web01
```
vagrant ssh app01
sudo systemctl restart tomcat.service

Then open <https://192.168.56.12> or <http://192.168.56.11>. The first run takes a while, mostly the
Maven build on `app01`.

Useful commands:

```bash
vagrant status
vagrant ssh app01
vagrant provision app01     # re-run one VM's script
vagrant destroy -f          # remove everything
```

## Verify

| VM    | Check (inside `vagrant ssh <vm>`)                      | Expected              |
|-------|---------------------------------------------------------|-----------------------|
| db01  | `mysql -u admin -padmin123 accounts -e "show tables;"`  | application tables    |
| mc01  | `systemctl status memcached`                            | active (running)      |
| rmq01 | `systemctl status rabbitmq-server`                      | active (running)      |
| app01 | `curl -I http://localhost:8080`                         | 302 -> `/login`       |
| web01 | `curl -I http://localhost`                              | 302 -> `/login`       |

## Notes

- Passwords in the scripts (`admin123`, `test/test`) are **demo values for a local lab only**. Never reuse them anywhere real.
- The scripts run only on the first `vagrant up` of each VM; use `vagrant provision` to re-run them.
