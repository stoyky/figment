flarevm:
	@echo "Building FLARE VM..."
	packer build -var-file=packer/flarevm/flarevm.pkrvars.hcl packer/flarevm/flarevm.pkr.hcl

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
