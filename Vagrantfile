Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/jammy64"
    config.vm.hostname = "gitops-lab"

    config.vm.network "private_network", type: "dhcp"
    config.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 2
    end

    config.vm.provision "shell", path: "bootstrap.sh"
  end

  