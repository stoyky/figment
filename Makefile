flarevm-vmware:
	@echo "Building FLARE VM vmware..."
	packer init packer/flarevm/flarevm.pkr.hcl 
	packer build -on-error=ask --only vmware-iso.flarevm -var-file=packer/flarevm/flarevm.pkrvars.hcl packer/flarevm/flarevm.pkr.hcl 

flarevm-virtualbox:
	@echo "Building FLARE VM virtualbox..."
	packer init packer/flarevm/flarevm.pkr.hcl 
	packer build -on-error=ask --only virtualbox-iso.flarevm -var-file=packer/flarevm/flarevm.pkrvars.hcl packer/flarevm/flarevm.pkr.hcl 

flarevm-qemu:
	@echo "Building FLARE VM qemu..."
	packer init packer/flarevm/flarevm.pkr.hcl 
	packer build -on-error=ask --only qemu.flarevm -var-file=packer/flarevm/flarevm.pkrvars.hcl packer/flarevm/flarevm.pkr.hcl 

remnux-vmware: 
	@echo "Building REMnux..."
	packer init packer/remnux/remnux.pkr.hcl 
	packer build -on-error=ask --only vmware-vmx.remnux -var-file=packer/remnux/remnux.pkrvars.hcl packer/remnux/remnux.pkr.hcl

remnux-virtualbox:
	@echo "Building REMnux..."
	packer init packer/remnux/remnux.pkr.hcl 
	packer build --force -on-error=ask --only virtualbox-ovf.remnux -var-file=packer/remnux/remnux.pkrvars.hcl packer/remnux/remnux.pkr.hcl

remnux-qemu:
	@echo "Building REMnux..."
	packer init packer/remnux/remnux.pkr.hcl 
	PACKER_LOG=1 packer build --force -on-error=ask --only qemu.remnux -var-file=packer/remnux/remnux.pkrvars.hcl packer/remnux/remnux.pkr.hcl

convert-cape-server:
	@echo "Converting OVA to VMX..."
	packer init packer/cape-server/cape-server.pkr.hcl 
	packer build -on-error=ask --only null.cape-server -var-file=packer/cape-server/cape-server.pkrvars.hcl packer/cape-server/cape-server.pkr.hcl

cape-server-vmware: 
	@echo "Building CAPE Server..."
	packer init packer/cape-server/cape-server.pkr.hcl 
	PACKER_LOG=1 packer build -on-error=ask --only vmware-iso.cape-server -var-file=packer/cape-server/cape-server.pkrvars.hcl packer/cape-server/cape-server.pkr.hcl

cape-guest-win10-vmware: 
	@echo "Building CAPE guest Windows 10..."
	packer init packer/cape-guest-win10/cape-guest-win10.pkr.hcl 
	packer build -on-error=ask --only vmware-iso.cape-guest-win10 -var-file=packer/cape-guest-win10/cape-guest-win10.pkrvars.hcl packer/cape-guest-win10/cape-guest-win10.pkr.hcl

cape-guest-win10-virtualbox: 
	@echo "Building CAPE guest Windows 10..."
	packer init packer/cape-guest-win10/cape-guest-win10.pkr.hcl 
	packer build -on-error=ask --only virtualbox-iso.cape-guest-win10 -var-file=packer/cape-guest-win10/cape-guest-win10.pkrvars.hcl packer/cape-guest-win10/cape-guest-win10.pkr.hcl

cape-guest-win10-qemu: 
	@echo "Building CAPE guest Windows 10..."
	packer init packer/cape-guest-win10/cape-guest-win10.pkr.hcl 
	PACKER_LOG=1 packer build -on-error=ask --only qemu.cape-guest-win10 -var-file=packer/cape-guest-win10/cape-guest-win10.pkrvars.hcl packer/cape-guest-win10/cape-guest-win10.pkr.hcl

cape-guest-win11-qemu: 
	@echo "Building CAPE guest Windows 11..."
	packer init packer/cape-guest-win11/cape-guest-win11.pkr.hcl 
	PACKER_LOG=1 packer build -on-error=ask --only qemu.cape-guest-win11 -var-file=packer/cape-guest-win11/cape-guest-win11.pkrvars.hcl packer/cape-guest-win11/cape-guest-win11.pkr.hcl

clean-flarevm: 
	@echo "Cleaning temporary directories for REMnux..."
	rm -rf temp/flarevm-virtualbox/
	rm -rf temp/flarevm-vmware/
	rm -rf output-flarevm/

clean-remnux: 
	@echo "Cleaning temporary directories for REMnux..."
	rm -rf temp/remnux-virtualbox/
	rm -rf temp/remnux-vmware/
	rm -rf output-remnux/

clean:
	@echo "Cleaning ALL output directories..."
	rm -rf temp/
	rm -rf output-*/

all-vmware: flarevm-vmware remnux-vmware 
all-virtualbox: flarevm-virtualbox remnux-virtualbox
