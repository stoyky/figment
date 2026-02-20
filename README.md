<h1 align="center">
  <br>
  Figment
  <br>
</h1>

<h4 align="center"> Spin up a fully configured, host‑only malware analysis lab with FlareVM and REMnux using a few repeatable commands.</h4>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#tech-stack">Tech stack</a> •
  <a href="#quick-start-prebuilt">Prebuilt Vagrant Boxes</a> •
  <a href="#quick-start-customizable">Quick Start</a> 
  <a href="#project-structure">Project Structure</a> •
  <a href="#configuration">Configuration</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#security">Security</a> •
  <a href="#changelog">Changelog</a> •
  <a href="#license">License</a>
</p>

## Features

- One‑command build of FlareVM (Windows) and REMnux (Linux) lab images using Packer.  
- Automated provisioning via Ansible from base ISO (FlareVM) and OVA/VMX (REMnux).
- Isolated host‑only network between FlareVM and REMnux for network traffic capturing. 
- Internet access only during provisioning, then switched to a safe offline lab topology.  

## Tech stack

- **Packer**: image building for VMware / VirtualBox (depending on your builders).  
- **Ansible**: provisioning FlareVM and REMnux (packages, tools, post‑install config).  
- **Hypervisors**: VMware Workstation and VirtualBox are supported.  
- **Vagrant**: Optionally build Vagrant boxes after provisioning with Packer.

---

## Pre-built Vagrant Boxes
Pre-built Vagrant boxes have been uploaded to the Hashicorp Public Boxes Catalog:

https://portal.cloud.hashicorp.com/vagrant/discover/figment/flarevm

https://portal.cloud.hashicorp.com/vagrant/discover/figment/remnux

To run these:
- `cd figment/vagrant/<flarevm or remnux>`
- `vagrant up --provider=<vmware_desktop or virtualbox> --provision` 
- Do not forget to disable NAT and take a base snapshots after running the VMs. 

## Quickstart

Follow these steps if you want to customize the resulting VMs / Vagrant boxes:

1. **Prerequisites**
    - A working Packer installation (>= 1.7) 
      - https://developer.hashicorp.com/packer/install
    
    - VMware Workstation / Fusion or VirtualBox
      - https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion
      - https://www.virtualbox.org/wiki/Downloads
    - A working OVFtool installation (for REMnux only)
      - https://developer.broadcom.com/tools/open-virtualization-format-ovf-tool/latest
    - REMnux OVA:
      - https://download.remnux.org/202601/remnux-noble-amd64.ova
      - https://download.remnux.org/202601/remnux-noble-amd64-virtualbox.ova 
    - Windows 10 en-US ISO for FlareVM:
      - https://www.microsoft.com/en-us/software-download/windows10ISO

  
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

4. **Downloading REMnux OVA and FlareVM Windows 10 ISO**

    Place the OVA and ISO in the **assets/remnux** and **assets/flarevm** folder in the root directory. 

5. **Edit configurations**

    The configuration files for the VM's can be found at: (see <a href="#configuration">**Configuration**</a> for more info).

    For general packer build settings:
    - packer/flarevm/flarevm.pkrvars.hcl
    - packer/remnux/remnux.pkrvars.hcl

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
        make flarevm-<vmware/virtualbox>
        ```

    - Build REMnux:

        ```bash
        make remnux-<vmware/virtualbox>
        ```

    - Or build all (for example via a Makefile target):

        ```bash
        make all-<vmware/virtualbox>
        ```
 7. **Disable NAT**
    - Disable or remove your NAT adapter either in the hypervisor or in the OS to ensure proper isolation. 
      - FlareVM: Disable the NAT adapter in the OS or in the virtualization platform.
        ```powershell
        Disable-NetAdapter -Name "nat" 
        ```
      - REMnux: Disable NAT adapter through the command line:
        ```bash
        sudo ip link set ens33 down
        ```
 8. **Test network**
    - REMnux: 
      1. Make sure NAT is disabled (see previous step) 
      2. Start INetSim `inetsim`
      3. Start FakeDNS `sudo python3 /opt/fakedns/bin/fakedns.py`
    - FlareVM: 
      1. Make sure NAT is disabled (see previous step) 
      2. Run `nslookup` to check whether your DNS is returning the correct IP.
      3. Browse to any website to check whether requests are intercepted by INetSim / FakeDNS. 
---

## Project structure

```text
.
├── ansible # Ansible playbooks
│   ├── playbooks
│   │   ├── flarevm.yml
│   │   └── remnux.yml
│   └── roles
│       ├── flarevm
│       │   ├── files
│       │   │   └── custom-config.xml
│       │   ├── tasks
│       │   │   └── main.yml
│       │   └── vars
│       │       └── main.yml
│       └── remnux
│           └── tasks
│               └── main.yml
├── assets
│   ├── flarevm
|   ├── remnux    
│   ├── README.md
├── packer
│   ├── flarevm
│   │   ├── flarevm.pkr.hcl
│   │   ├── flarevm.pkrvars.hcl
│   │   ├── autounattend
│   │   │   └── autounattend.xml
│   │   ├── scripts
│   │   │   └── enable-ssh.ps1
│   │   ├── Vagrantfile
│   └── remnux
│       ├── remnux.pkr.hcl
│       ├── remnux.pkrvars.hcl
│       ├── Vagrantfile
├── vagrant
│   ├── flarevm
│   │   ├── Vagrantfile
│   └── remnux
│       ├── Vagrantfile
├── Makefile
├── requirements.txt
├── README.md
├── LICENSE.md
```

- `packer/flarevm`: Packer templates and Ansible provisioning for FlareVM.
- `packer/remnux`: Packer templates and Ansible provisioning for REMnux based on the upstream OVA/VMX.
- `ansible/`: shared roles and inventories used during Packer builds.
- `vagrant/`: Vagrantfiles to launch Vagrant boxes.
- `Makefile`: optional command shortcuts for selective builds and lab lifecycle.

## Configuration

You can tune image settings, network parameters, and credentials via `.pkrvars.hcl` and Vagrant variables.

### Packer variables

Each image has its own `*.pkr.hcl` and `*.pkrvars.hcl` with variables such as:

- `iso_url`, `iso_sha256` for Windows / FlareVM base.
- `source_path` for the converted REMnux VMX.
- `user`, `password` / `ssh_username`, `ssh_password` for communicators.
- `cpus`, `memory`, `disk_size` per VM.
- `hostonly_ip`, `default_gateway`, `dns_ip` to configure the lab network (for example `172.16.53.x`). Choose these settings according to your host-only network settings in VMWare / Virtualbox.

Example `flarevm.pkrvars.hcl` (simplified):

```hcl
iso_url          = "iso/Win10_22H2_English_x64v1.iso"
iso_sha256       = "..."
user             = "admin"
password         = "password"
vm_name          = "flarevm"
cpus             = 4
memory           = 8192
disk_size        = 60000
hostonly_ip      = "192.168.56.20"
default_gateway  = "192.168.56.10"
dns_ip           = "192.168.56.10"
```

Example `remnux.auto.pkrvars.hcl` (simplified):

```hcl
source_path             = "temp/remnux/remnux.vmx"
display_name            = "remnux"
ssh_username            = "remnux"
ssh_password            = "malware"
hostonly_ip             = "192.168.56.10"
```

### Network topology

The lab runs with two phases of networking:

- **Build time**: internet‑enabled (NAT/bridged) so Packer + Ansible can download tools (FlareVM tooling, REMnux packages, etc.).
- **Lab time**: NAT is disabled and host‑only network is enabled where FlareVM and REMnux share a private subnet and can only communicate with each other.

## Contributing

Contributions are welcome:

- Open issues for bugs, feature requests, questions about configuration, or documentation improvements.
- Requests for additional providers (Qemu / Proxmox) etc. are welcome too.
- Submit pull requests with clear descriptions and small, focused changes.

## Security

This project is explicitly intended for malware analysis and should be used only in isolated, controlled environments. *Never expose these VMs directly to production networks.* Please check the network settings for the VM's, and ensure NAT / internet access is disabled when analysing samples. 

## Changelog

* v1.0.0 - Initial release

## Credits
- [FlareVM](https://github.com/mandiant/flare-vm) - Installation scripts for FlareVM

- [REMnux](https://remnux.org/) - Ready to run OVA images

- [Packer](https://developer.hashicorp.com/packer) - Building images

- [Vagrant](https://developer.hashicorp.com/vagrant) - Building Vagrant boxes

- [Ansible](https://docs.ansible.com/) - Image provisioning

## License

This project is licensed under the MIT License. See the `LICENSE.md` file for details.

> Created by [Remy Jaspers](https://github.com/stoyky)
