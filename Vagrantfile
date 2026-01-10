Vagrant.configure("2") do |config|
  # REMnux
  # config.vm.define "remnux" do |remnux|
  #   remnux.vm.box = "remnux"
  #   remnux.vm.hostname = "remnux"

  #   # Host-only / private network (static IP example)
  #   remnux.vm.network "private_network", ip: "192.168.56.10"  # same subnet as flarevm[web:11]

  #   remnux.vm.provider "vmware_desktop" do |vp|
  #     vp.memory = "2048"
  #     vp.gui    = true
  #   end
  # end

  # FLARE VM
  config.vm.define "flarevm" do |flarevm|
    flarevm.vm.box = "flarevm"
    flarevm.vm.hostname = "flarevm"
    flarevm.vm.guest = :windows
    flarevm.ssh.username = "admin"
    flarevm.ssh.password = "password"
    flarevm.ssh.shell = "powershell"
    flarevm.ssh.insert_key = false

    # Same host-only / private network
    flarevm.vm.network auto_config: false

    # flarevm.vm.provision "shell", path: "fix_network.ps1", privileged: true, powershell_elevated_interactive: true, upload_path: "C:/Users/admin/Desktop/fix_network.ps1"
    flarevm.vm.synced_folder '.', '/vagrant', disabled: true

    flarevm.vm.provider "vmware_desktop" do |vp|
      vp.memory = "4096"
      vp.gui    = true
    end
  end
end
