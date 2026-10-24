# تثبيت البلجنز المطلوبة تلقائيًا لو ناقصة، ثم إعادة تشغيل نفس الأمر
required_plugins = %w(vagrant-hostmanager)
missing_plugins = required_plugins.reject { |p| Vagrant.has_plugin?(p) }
unless missing_plugins.empty?
  puts "Installing missing plugins: #{missing_plugins.join(', ')}"
  system("vagrant plugin install #{missing_plugins.join(' ')}") || abort("Plugin installation failed")
  exec "vagrant #{ARGV.join(' ')}"
end

Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true

### DB vm  ####
  config.vm.define "db01" do |db01|
    db01.vm.box = "eurolinux-vagrant/centos-stream-9"
    db01.vm.box_version = "9.0.43"
    db01.vm.hostname = "db01"
    db01.vm.network "private_network", ip: "192.168.56.15"
    db01.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
    end
    db01.vm.provision "shell", path: "mysql.sh"
  end

### Memcache vm  ####
  config.vm.define "mc01" do |mc01|
    mc01.vm.box = "eurolinux-vagrant/centos-stream-9"
    mc01.vm.box_version = "9.0.43"
    mc01.vm.hostname = "mc01"
    mc01.vm.network "private_network", ip: "192.168.56.14"
    mc01.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
    mc01.vm.provision "shell", path: "memcache.sh"
  end

### RabbitMQ vm  ####
  config.vm.define "rmq01" do |rmq01|
    rmq01.vm.box = "eurolinux-vagrant/centos-stream-9"
    rmq01.vm.box_version = "9.0.43"
    rmq01.vm.hostname = "rmq01"
    rmq01.vm.network "private_network", ip: "192.168.56.13"
    rmq01.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
    rmq01.vm.provision "shell", path: "rabbitmq.sh"
  end

### tomcat vm ###
  config.vm.define "app01" do |app01|
    app01.vm.box = "eurolinux-vagrant/centos-stream-9"
    app01.vm.box_version = "9.0.43"
    app01.vm.hostname = "app01"
    app01.vm.network "private_network", ip: "192.168.56.12"
    app01.vm.provider "virtualbox" do |vb|
      vb.memory = "6144"
    end
    app01.vm.provision "shell", path: "tomcat.sh"
  end

### Nginx VM ###
  config.vm.define "web01" do |web01|
    web01.vm.box = "ubuntu/jammy64"
    web01.vm.hostname = "web01"
    web01.vm.network "private_network", ip: "192.168.56.11"
    web01.vm.provider "virtualbox" do |vb|
      vb.gui = true
      vb.memory = "1024"
    end
    web01.vm.provision "shell", path: "nginx.sh"
  end

end
