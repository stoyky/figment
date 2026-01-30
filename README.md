# 🧪 Malware Lab Builder

[![Status](https://img.shields.io/badge/status-experimental-yellow)](https://github.com/your-user/your-repo)  
[![Made with Packer](https://img.shields.io/badge/infra-packer-blue)](https://www.packer.io/)  
[![Automation](https://img.shields.io/badge/automation-ansible%20%7C%20vagrant-green)](https://www.ansible.com/)  
[![License: MIT](https://img.shields.io/badge/license-MIT-lightgrey)](./LICENSE)

Spin up a fully configured, host‑only malware analysis lab with **FlareVM** and **REMnux** using a few repeatable commands.

---

## 📚 Table of Contents

- ✨ Features
- 📦 Tech stack
- 🚀 Quick start
- 🧱 Project structure
- ⚙️ Configuration
- 🧪 Usage
- 🛠️ Development
- 🙋 FAQ
- 🤝 Contributing
- 🛡️ Security
- 📜 License

---

## ✨ Features

- One‑command build of FlareVM (Windows) and REMnux (Linux) lab images using Packer.  
- Automated provisioning via Ansible from base ISO (FlareVM) and OVA/VMX (REMnux), no manual clicks.  
- Isolated host‑only network between FlareVM and REMnux so they can talk to each other but remain off the internet.  
- Internet access only during provisioning, then switched to a safe offline lab topology.  

---

## 📦 Tech stack

- **Packer**: image building for VMware / VirtualBox (depending on your builders).  
- **Ansible**: provisioning FlareVM and REMnux (packages, tools, post‑install config).  
- **Hypervisors**: VMware Workstation / Fusion and/or VirtualBox, depending on your local setup.  

---

## 🚀 Quick start


1. **Prerequisites**
    - A working Packer installation (>= 1.7) 
      - https://developer.hashicorp.com/packer/install
    
    - VMware Workstation / Fusion or VirtualBox
      - https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion
      - https://www.virtualbox.org/wiki/Downloads
    - A working OVFtool installation (for REMnux only)
      - https://developer.broadcom.com/tools/open-virtualization-format-ovf-tool/latest
    - REMnux OVA:
      -  https://download.remnux.org/202601/remnux-noble-amd64.ova
      - https://download.remnux.org/202601/remnux-noble-amd64-virtualbox.ovaand 
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

    The configuration files for the VM's can be found in (see **Configuration** for more info):
    - packer/flarevm/flarevm.pkrvars.hcl
    - packer/remnux/remnux.pkrvars.hcl

6. **Build images**

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

---

## 🧱 Project structure

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
│   │   ├── autounattend
│   │   │   └── autounattend.xml
│   │   ├── flarevm.pkr.hcl
│   │   ├── flarevm.pkrvars.hcl
│   │   ├── scripts
│   │   │   └── enable-ssh.ps1
│   └── remnux
│       ├── remnux.pkr.hcl
│       ├── remnux.pkrvars.hcl
├── Makefile
├── README.md
├── requirements.txt
```

- `packer/flarevm`: Packer templates and Ansible provisioning for FlareVM.
- `packer/remnux`: Packer templates and Ansible provisioning for REMnux based on the upstream OVA/VMX.
- `ansible/`: shared roles and inventories used during Packer builds.
- `Makefile`: optional command shortcuts for selective builds and lab lifecycle.

---

## ⚙️ Configuration

You can tune image settings, network parameters, and credentials via `.pkrvars.hcl` and Vagrant variables.

### Packer variables

Each image has its own `*.pkr.hcl` and `*.pkrvars.hcl` with variables such as:

- `iso_url`, `iso_sha256` for Windows / FlareVM base.
- `source_path` for the converted REMnux VMX.
- `user`, `password` / `ssh_username`, `ssh_password` for communicators.
- `cpus`, `memory`, `disk_size` per VM.
- `hostonly_ip`, `default_gateway`, `dns_ip` to configure the lab network (for example `172.16.53.x`).

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
hostonly_ip      = "192.168.56.222"
default_gateway  = "192.168.56.111"
dns_ip           = "192.168.56.111"
```

Example `remnux.auto.pkrvars.hcl` (simplified):

```hcl
source_path             = "temp/remnux/remnux.vmx"
display_name            = "remnux"
ssh_username            = "remnux"
ssh_password            = "malware"
hostonly_ip             = "192.168.56.111"
```


### Network topology

The lab runs with two phases of networking:

- **Build time**: internet‑enabled (NAT/bridged) so Packer + Ansible can download tools (FlareVM tooling, REMnux packages, etc.).
- **Lab time**: NAT is disabled and host‑only network is enabled where FlareVM and REMnux share a private subnet and can only communicate with each other.

---

## 🤝 Contributing

Contributions are welcome:

- Open issues for bugs, feature requests, or documentation improvements.
- Submit pull requests with clear descriptions and small, focused changes.

---

## 🛡️ Security

This project is explicitly intended for malware analysis and should be used only in isolated, controlled environments.

- Never expose these VMs directly to production networks.
- Do not reuse credentials from this lab elsewhere.
- Treat all samples and generated artifacts as potentially dangerous.

---

## 📜 License

``This project is licensed under the MIT License. See the `LICENSE` file for details.``

