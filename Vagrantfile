Vagrant.configure("2") do |config|
  # REMnux
  config.vm.define "remnux" do |remnux|
    remnux.vm.box = "remnux"
    remnux.vm.hostname = "remnux"

    remnux.vm.network "private_network", type: "dhcp", adapter: 0

    remnux.vm.provider "vmware_desktop" do |vp|
      vp.memory = "2048"
      vp.gui    = true
      vp.ssh_info_public = true
    end
  end

  # FLARE VM
  config.vm.define "flarevm" do |flarevm|
    flarevm.vm.box = "flarevm"
    flarevm.vm.hostname = "flarevm"
    flarevm.vm.guest = :windows
    flarevm.ssh.username = "admin"
    flarevm.ssh.password = "password"
    flarevm.ssh.shell = "powershell"
    flarevm.ssh.insert_key = false

    flarevm.vm.network "private_network", type: "dhcp", adapter: 0

    flarevm.vm.synced_folder '.', '/vagrant', disabled: true

    flarevm.vm.provider "vmware_desktop" do |vp|
      vp.memory = "4096"
      vp.gui    = true
      vp.ssh_info_public = true
    end
  end
end
