flarevm-vmware:
	@echo "Building FLARE VM vmware..."
	packer init packer/flarevm/flarevm.pkr.hcl 
	packer build -on-error=ask --only vmware-iso.flarevm -var-file=packer/flarevm/flarevm.pkrvars.hcl packer/flarevm/flarevm.pkr.hcl 

flarevm-virtualbox:
	@echo "Building FLARE VM virtualbox..."
	packer init packer/flarevm/flarevm.pkr.hcl 
	packer build -on-error=ask --only virtualbox-iso.flarevm -var-file=packer/flarevm/flarevm.pkrvars.hcl packer/flarevm/flarevm.pkr.hcl 

convert:
	@echo "Converting OVA to VMX..."
	packer init packer/remnux/remnux.pkr.hcl 
	packer build -on-error=ask --only null.remnux -var-file=packer/remnux/remnux.pkrvars.hcl packer/remnux/remnux.pkr.hcl

remnux-vmware: convert
	@echo "Building REMnux..."
	packer init packer/remnux/remnux.pkr.hcl 
	packer build -on-error=ask --only vmware-vmx.remnux -var-file=packer/remnux/remnux.pkrvars.hcl packer/remnux/remnux.pkr.hcl

remnux-virtualbox:
	@echo "Building REMnux..."
	packer init packer/remnux/remnux.pkr.hcl 
	packer build --force -on-error=ask --only virtualbox-ovf.remnux -var-file=packer/remnux/remnux.pkrvars.hcl packer/remnux/remnux.pkr.hcl

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
