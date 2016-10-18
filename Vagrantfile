# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "hashicorp/precise32"

  config.vm.define :devops_dev do |web_config|
    web_config.vm.network "private_network", ip: "192.168.50.10"
    web_config.vm.provision "puppet" do |puppet|
        puppet.manifest_file = "devops-dev.pp"
    end
  end
  
  config.vm.provider "virtualbox" do |vb|
     vb.gui = true
     vb.memory = "8192"
  end

end