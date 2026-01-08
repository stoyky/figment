Vagrant.configure("2") do |config|
  # REMnux
  config.vm.define "remnux" do |remnux|
    remnux.vm.box = "remnux"
    remnux.vm.hostname = "remnux"

    # Host-only / private network (static IP example)
    remnux.vm.network "private_network", ip: "192.168.56.10"  # same subnet as flarevm[web:11]

    remnux.vm.provider "vmware_desktop" do |vp|
      vp.memory = "2048"
      vp.gui    = true
    end
  end

  # FLARE VM
  config.vm.define "flarevm" do |flare|
    flare.vm.box = "flarevm"
    flare.vm.hostname = "flarevm"
    flare.ssh.username = "admin"
    flare.ssh.password = "password"
    flare.ssh.shell = "powershell"

    # Same host-only / private network
    flare.vm.network "private_network", ip: "192.168.56.20"  # same subnet as remnux[web:11]

    flare.vm.provider "vmware_desktop" do |vp|
      vp.memory = "4096"
      vp.gui    = true
    end
  end
end
