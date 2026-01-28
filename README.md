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
- Vagrant boxes generated for consistent, reproducible lab spins across machines.  

---

## 📦 Tech stack

- **Packer**: image building for VMware / VirtualBox (depending on your builders).  
- **Ansible**: provisioning FlareVM and REMnux (packages, tools, post‑install config).  
- **Vagrant**: lab orchestration on top of built boxes.  
- **Hypervisors**: VMware Workstation / Fusion and/or VirtualBox, depending on your local setup.  

---

## 🚀 Quick start

1. **Clone the repository**

   ```bash
   git clone https://github.com/your-user/malware-lab-builder.git
   cd malware-lab-builder
```

2. **Install prerequisites**
    - Packer (>= 1.7)
    - Ansible
    - Vagrant (+ VMware or VirtualBox provider)
    - VMware Workstation / Fusion or VirtualBox
    - REMnux OVA and Windows ISO for FlareVM placed in the expected paths (see Configuration).
3. **Build images**
    - Build FlareVM:

```bash
packer build packer/flarevm
```

    - Build REMnux:

```bash
packer build packer/remnux
```

    - Or build all (for example via a Makefile target):

```bash
make all
```

4. **Start the lab**

From the `vagrant/` directory:

```bash
vagrant up flarevm
vagrant up remnux
# or
vagrant up
```


---

## 🧱 Project structure

```text
.
├── ansible
│   ├── flarevm
│   ├── playbooks
│   │   ├── flarevm.yml
│   │   └── remnux.yml
│   ├── remnux
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
│   │   └── Vagrantfile
│   └── remnux
│       ├── remnux.pkr.hcl
│       ├── remnux.pkrvars.hcl
│       └── Vagrantfile
├── Makefile
├── README.md
├── requirements.txt
```

- `packer/flarevm`: Packer templates and Ansible provisioning for FlareVM.
- `packer/remnux`: Packer templates and Ansible provisioning for REMnux based on the upstream OVA/VMX.
- `vagrant/`: multi‑VM Vagrantfile defining FlareVM and REMnux plus host‑only networking.
- `ansible/`: shared roles and inventories used during Packer builds.
- `Makefile`: optional command shortcuts for selective builds and lab lifecycle.

---

## ⚙️ Configuration

You can tune image settings, network parameters, and credentials via `.pkrvars.hcl` and Vagrant variables.

### Packer variables

Each image has its own `*.pkr.hcl` and `*.auto.pkrvars.hcl` with variables such as:

- `iso_url`, `iso_sha256` for Windows / FlareVM base.
- `source_path` for the converted REMnux VMX.
- `user`, `password` / `ssh_username`, `ssh_password` for communicators.
- `cpus`, `memory`, `disk_size` per VM.
- `hostonly_ip`, `default_gateway`, `dns_ip` to configure the lab network (for example `172.16.53.x`).

Example `flarevm.auto.pkrvars.hcl` (simplified):

```hcl
iso_url        = "iso/Win10.iso"
iso_sha256     = "..."
user           = "admin"
password       = "packerpass"
vm_name        = "flarevm"
cpus           = 4
memory         = 8192
disk_size      = 60000
hostonly_ip    = "172.16.53.42"
default_gateway = "172.16.53.1"
dns_ip         = "172.16.53.1"
```

Example `remnux.auto.pkrvars.hcl` (simplified):

```hcl
source_path             = "temp/remnux/remnux.vmx"
display_name            = "remnux"
ssh_username            = "remnux"
ssh_password            = "malware"
hostonly_ip             = "172.16.53.111"
ethernet0_pcislotnumber = 33
ethernet1_pcislotnumber = 36
```


### Network topology

The lab runs with two phases of networking:

- **Build time**: internet‑enabled (NAT/bridged) so Packer + Ansible can download tools (FlareVM tooling, REMnux packages, etc.).
- **Lab time**: host‑only network where FlareVM and REMnux share a private subnet and can only communicate with each other and the analyst host as needed.

You can change the CIDR, IPs, and interface names via Packer variables and the Vagrantfile.

---

## 🧪 Usage

Once the lab is up, you can start analyzing samples inside FlareVM and use REMnux for network and host‑based tooling.

Typical flow:

1. **Bring up the lab**

```bash
cd vagrant
vagrant up
```

2. **Access FlareVM**
    - Via RDP to the VM’s host‑only IP and Windows user you configured.
    - FlareVM tooling (IDA, x64dbg, etc.) is expected to be preinstalled by your Ansible scripts.
3. **Access REMnux**
    - Via SSH or console (depending on your Vagrant provider configuration) to the host‑only IP.
    - Use REMnux tools (network forensics, sandbox helpers, etc.) to support analysis.
4. **Verify connectivity**
    - From FlareVM, ping REMnux host‑only IP.
    - From REMnux, ping FlareVM host‑only IP.
5. **Tear down the lab**

```bash
cd vagrant
vagrant halt
vagrant destroy
```


---

## 🛠️ Development

The project is designed to be easily extendable for additional images or hypervisors.

- Add new Packer sources (e.g., VirtualBox/QEMU) alongside existing VMware builders.
- Reuse common Ansible roles for shared tooling or baseline hardening.
- Extend the Vagrantfile with extra VMs (e.g., domain controller, sinkhole, etc.) connected to the same host‑only network.

Basic workflow:

```bash
# Validate configs
packer validate packer/flarevm
packer validate packer/remnux

# Build images
make flarevm
make remnux

# Run lab
cd vagrant && vagrant up
```


---

## 🙋 FAQ

### Why use host‑only networking?

Host‑only networking lets FlareVM and REMnux see each other while staying isolated from the wider internet, which is crucial when handling live malware.

### Can I build only one of the images?

Yes. You can run only the specific Packer build (for example `packer build packer/flarevm`) and later `vagrant up flarevm` to start only that VM.

### Does this change the original REMnux OVA?

The REMnux workflow converts the OVA to VMX and then builds a Vagrant box from it; depending on your configuration, you can choose between a “no‑change” clone or a minimally provisioned variant.

---

## 🤝 Contributing

Contributions are welcome:

- Open issues for bugs, feature requests, or documentation improvements.
- Submit pull requests with clear descriptions and small, focused changes.

Please follow any existing `CONTRIBUTING.md` and coding style guidelines in this repository.

---

## 🛡️ Security

This project is explicitly intended for malware analysis and should be used only in isolated, controlled environments.

- Never expose these VMs directly to production networks.
- Do not reuse credentials from this lab elsewhere.
- Treat all samples and generated artifacts as potentially dangerous.

---

## 📜 License

This project is licensed under the MIT License. See the `LICENSE` file for details.

```

