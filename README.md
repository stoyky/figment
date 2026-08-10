<h1 align="center">
  <br>
  Figment
  <br>
</h1>

<p align="center">
  <img width="450" alt="Figment Logo, adopted from https://github.com/mandiant/flare-vm/blob/main/Images/flarevm-logo.png" src="https://github.com/user-attachments/assets/ae2d0a47-4de6-4a89-8447-2914fec2214e" />
</p>

<h4 align="center"> Spin up a fully configured, host‑only malware analysis lab with FlareVM, REMnux and CAPE using a few repeatable commands.</h4>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#tech-stack">Tech stack</a> •
  <a href="#prebuilt-vagrant-boxes">Prebuilt Vagrant Boxes</a> •
  <a href="#quick-start">Quick Start</pa> •
  <a href="#project-structure">Project Structure</a> •
  <a href="#configuration">Configuration</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#security">Security</a> •
  <a href="#changelog">Changelog</a> •
  <a href="#license">License</a>
</p>

## Features

- One‑command build of FlareVM, REMnux and CAPE Server + Win10/11 Guest lab images using Packer.  
- Automated provisioning via Ansible from base ISO (FlareVM and CAPEv2) and OVA/VMX (REMnux).
- Isolated host‑only network between FlareVM and REMnux for network traffic capturing.  
- All targets support VMWare Workstation, Virtualbox and QEMU/KVM

## Tech stack

- **Packer**: image building for VMware / VirtualBox / QEMU/KVM (depending on your builders).  
- **Ansible**: provisioning FlareVM and REMnux (packages, tools, post‑install config).  
- **Hypervisors**: VMware Workstation, VirtualBox and QEMU/KVM are supported.  
- **Vagrant**: Optionally build Vagrant boxes after provisioning with Packer.

---
## Guide

See below for three different ways to get this project up and running. For a more elaborate guide on how to set this project up, please see my blog: 

Walkthrough on setting up FlareVM and REMnux:

https://www.remyjaspers.com/blog/figment/

Addendum on setting up CAPE:

https://www.remyjaspers.com/blog/figment2/

## Direct Import
If you don't care to install Vagrant, you can simply download the box file for the respective VM you want to import into your hypervisor from the link below:

https://portal.cloud.hashicorp.com/vagrant/discover/figment/

These box files are just compressed OVF/VMX files and disk VMDK files. 

- Download the box file you wish to import
- Extract the file you downloaded twice
- You will end up with a number of folders, one with the metadata (OVF/VMX) and one or more with disk files (VMDK)
- Copy the disk VMDK files to the folder containing the metadata (OVF/VMX)
- Import the OVF or VMX files in your hypervisor and you should be good to go

## Using Vagrant
The quickest way to get started is to use the prebuilt Vagrant boxes that have been uploaded to the Hashicorp Public Boxes Catalog:

https://portal.cloud.hashicorp.com/vagrant/discover/figment/

To run these boxes follow these steps:

- Install Vagrant: https://developer.hashicorp.com/vagrant/install
- (VMWare) Install VMWare plugin `vagrant plugin install vagrant-vmware-desktop`
- (VMWare) Install VMWare Utility: https://developer.hashicorp.com/vagrant/install/vmware
- Clone repo `git clone https://github.com/stoyky/figment.git`
- Navigate to the vagrant folder `cd figment/vagrant/<flarevm, remnux, cape-server>`
- Run `vagrant up --provider=<vmware_desktop, virtualbox, libvirt> --provision`
- Disable NAT and test the network (see Quickstart step 8 below). 
- Do not forget to disable Shared Folders, and take a base snapshot after running the VMs.

Note: The FlareVM/REMnux boxes are prebuilt with IP addresses 192.168.55.20 (FlareVM) and  192.168.55.10 (REMnux). Make sure you configure your Hypervisor to have a Host-only network with range 192.168.55.0/24. (Virtualbox) Ensure your host-only network is named vboxnet0. 

## Customizing using Packer + Ansible Templates

Follow these steps if you want to customize the resulting VMs / Vagrant boxes:

1. **Prerequisites**
    - A working Packer installation (>= 1.7) 
      - https://developer.hashicorp.com/packer/install
    
    - VMware Workstation / Fusion or VirtualBox
      - https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion
      - https://www.virtualbox.org/wiki/Downloads
    - A working OVFtool installation (for REMnux only)
      - https://developer.broadcom.com/tools/open-virtualization-format-ovf-tool/latest
    - (FlareVM) Windows 10 en-US or Windows 11 en-US (24H2) ISO:
      - https://www.microsoft.com/en-us/software-download/windows10ISO
      - https://os.click/
    - (REMnux) OVA:
      - https://download.remnux.org/202601/remnux-noble-amd64.ova
      - https://download.remnux.org/202601/remnux-noble-amd64-virtualbox.ova 
    - (CAPE) Ubuntu 24.04 LTS ISO:
      - https://nl.releases.ubuntu.com/releases/24.04.4/
  
2. **Clone the repository**

    ```bash
    git clone https://github.com/stoyky/figment.git
    cd figment
    ```
3. **Create a Python venv and install requirements**

    ```bash
    python -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    ```

4. **Downloading required OVA (REMnux) and ISO's (FlareVM an CAPE)**

    Place the OVA and ISO in the **assets** folder in the root directory. 

5. **Edit configurations**

    The configuration files for the VM's can be found at: (see <a href="#configuration">**Configuration**</a> for more info).

    For general packer build settings:
    - packer/flarevm/flarevm.pkrvars.hcl
    - packer/remnux/remnux.pkrvars.hcl
    - packer/cape-server/cape-server.pkrvars.hcl

    FlareVM:
    - ansible/roles/flarevm/files/custom-config-xml
      - Adjust this file to change the FlareVM tools you wish to install.

6. **Build images**
    - To ensure a clean build:
  
        ```bash
        make clean
        ```

    - Build FlareVM:

        ```bash
        make flarevm-<vmware/virtualbox/qemu>
        ```

    - Build REMnux:

        ```bash
        make remnux-<vmware/virtualbox/qemu>
        ```
    
    - Build CAPE:
        
        ```bash
        make cape-server-<vmware/virtualbox/qemu>

 7. **(FlareVM / REMnux) Disable NAT and Shared Folders**
    - Disable or remove your NAT adapter either in the hypervisor or in the OS to ensure proper isolation. 
      - FlareVM (elevated Powershell prompt):
        ```powershell
        Disable-NetAdapter -Name "nat" 
        ```
      - REMnux:
        ```bash
        sudo ip link set ens33 down
        ```
    - Make sure to disable Shared Folders in the Hypervisor for both VM's!
 8. **(FlareVM / REMnux) Test network**
    - REMnux: 
      1. Make sure NAT is disabled (see previous step) 
      2. Start INetSim `inetsim`
      3. Start FakeDNS `sudo python3 /opt/fakedns/bin/fakedns.py`
    - FlareVM: 
      1. Make sure NAT is disabled (see previous step) 
      2. Run `nslookup` to check whether your DNS is returning the correct IP.
      3. Browse to any website to check whether requests are intercepted by INetSim / FakeDNS. 
     - Note: if your hostonly settings happen to be removed during build or reboot you can easily reset them by running the scheduled task "Configure HostOnly Adapter"
       - Run it from Start -> Task Scheduler -> Task Scheduler Library -> Configure HostOnly Adapter or
       - schtasks.exe /run /tn "Configure HostOnly Adapter"

## Project Structure

- `packer/flarevm`: Packer templates and Ansible provisioning for FlareVM.
- `packer/remnux`: Packer templates and Ansible provisioning for REMnux based on the upstream OVA/VMX.
- `packer/cape-server`: Packer templates and Ansible provisioning for CAPEv2 based on Ubuntu ISO.
- `ansible/`: shared roles and inventories used during Packer builds.
- `vagrant/`: Vagrantfiles to launch Vagrant boxes.
- `Makefile`: Command shortcuts for selective builds and lab lifecycle.

## Configuration

You can tune image settings, network parameters, and credentials via `.pkrvars.hcl` and Vagrant variables.

### Packer variables

Each image has its own `*.pkr.hcl` and `*.pkrvars.hcl` with variables such as:

- `iso_url`, `iso_sha256` defines base image to use.
- `user`, `password` / `ssh_username`, `ssh_password` for the SSH communicator.
- `cpus`, `memory`, `disk_size` per VM.
- `hostonly_ip`, `default_gateway`, `dns_ip` to configure the lab network (for example `192.168.55.x`). Choose these settings according to your host-only network settings in VMWare / Virtualbox / QEMU.
- (CAPE) Specify the `cape_commit` variable to pin a specific CAPE commit hash. You may specify the `cape_machinery`, `cape_machinery_interface`, and any number of `replicas` for the Win10/11 guest VM's per your needs. MAC addresses and IP's will be generated based on the settings automatically. 

Example `flarevm.pkrvars.hcl` (shortened):

```hcl
iso_url          = "iso/Win10_22H2_English_x64v1.iso"
iso_sha256       = "SHA256:..."
user             = "admin"
password         = "password"
vm_name          = "flarevm"
cpus             = 4
memory           = 8192
disk_size        = 60000
hostonly_ip      = "192.168.55.20"
default_gateway  = "192.168.55.10"
dns_ip           = "192.168.55.10"
```

Example `remnux.pkrvars.hcl` (shortened):

```hcl
source_path             = "temp/remnux/remnux.vmx"
display_name            = "remnux"
ssh_username            = "remnux"
ssh_password            = "malware"
hostonly_ip             = "192.168.55.10"
```

Example `cape-server.pkrvars.hcl` (shortened):
```hcl
# CAPE Settings
cape_commit              = "e451de454137e0d44ab1ce1f72eae2e2bccfa78a"
cape_nested_virt         = true
cape_machinery           = "kvm"
cape_machinery_interface = "virbr1"

cape_guests = [
  {
    name              = "cape-guest-win10"
    platform          = "windows"
    arch              = "x64"
    replicas          = 1
    hostonly_offset   = 101
    mac_base_hostonly = "52:54:00:10:20"
    mac_base_nat      = "52:54:00:20:10"
  },
  {
    name              = "cape-guest-win11"
    platform          = "windows"
    arch              = "x64"
    replicas          = 1
    hostonly_offset   = 151
    mac_base_hostonly = "52:54:00:20:30"
    mac_base_nat      = "52:54:00:30:20"
  }
]
```

### Network topology

The lab runs with two phases of networking:

- **Build time**: internet‑enabled (NAT/bridged) so Packer + Ansible can download tools (FlareVM tooling, REMnux packages, etc.).
- **Lab time**: NAT is disabled and host‑only network is enabled where FlareVM and REMnux share a private subnet and can only communicate with each other.

## Contributing

Contributions are welcome:

- Open issues for bugs, feature requests, questions about configuration, or documentation improvements.
- Submit pull requests with clear descriptions and small, focused changes.

## Security

This project is explicitly intended for malware analysis and should be used only in isolated, controlled environments. *Never expose these VMs directly to production networks.* Please check the network settings for the VM's, and ensure NAT / internet access / Shared Folders are disabled when analysing samples. The author of this project is not in any way shape or form responsible for the consequences of using these scripts. 

## Changelog

* v1.0.0 - Initial release
* v1.0.1 - (FlareVM) adjusted autounattend to also work for Windows 11
* v1.1.0 - Major update: Now supports building CAPEv2 Server and Win10/11 Guest images, all builds have a QEMU target.
* v1.1.1 - (CAPE) Added experimental Ubuntu 24.04 LTS Guest image for Linux analysis
* v1.1.2 - (CAPE) Added support for providing custom configurations in custom/conf to override defaults

## Credits
- [FlareVM](https://github.com/mandiant/flare-vm) - Installation scripts for FlareVM

- [REMnux](https://remnux.org/) - Ready to run OVA images

- [Packer](https://developer.hashicorp.com/packer) - Building images

- [Vagrant](https://developer.hashicorp.com/vagrant) - Building Vagrant boxes

- [Ansible](https://docs.ansible.com/) - Image provisioning

- [C. Schneegans Autounattend Generator](https://github.com/cschneegans/unattend-generator) - Windows 10/11 Autounattend Files Generator

- [os.click](https://os.click/en) - Archive of Windows 10/11 and Ubuntu/Debian ISO's.

## License

This project is licensed under the MIT License. See the `LICENSE.md` file for details.

> Created by [Remy Jaspers](https://github.com/stoyky)
