flarevm-vmware:
	@echo "Building FLARE VM vmware..."
	packer build --only vmware-iso.flarevm -var-file=packer/flarevm/flarevm.pkrvars.hcl packer/flarevm/flarevm.pkr.hcl 

flarevm-virtualbox:
	@echo "Building FLARE VM virtualbox..."
	packer build --only virtualbox-iso.flarevm -var-file=packer/flarevm/flarevm.pkrvars.hcl packer/flarevm/flarevm.pkr.hcl 

convert:
	@echo "Converting OVA to VMX..."
	packer build packer/remnux/convert.pkr.hcl

remnux: convert
	@echo "Building REMnux..."
	packer build -var-file=packer/remnux/remnux.pkrvars.hcl packer/remnux/remnux.pkr.hcl

clean-flarevm: 
	@echo "Cleaning temporary directories for REMnux..."
	rm -rf temp/flarevm/
	rm -rf output-flarevm/

clean-remnux: 
	@echo "Cleaning temporary directories for REMnux..."
	rm -rf temp/remnux/
	rm -rf output-remnux/

all: flarevm remnux
