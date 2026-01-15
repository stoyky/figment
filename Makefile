flarevm:
	@echo "Building FLARE VM..."
	packer build packer/flarevm/flarevm.pkr.hcl
	vagrant box add remnux boxes/flarevm.box --force
	cd packer/remnux && vagrant up

remnux: clean convert
	@echo "Building REMnux..."
	packer build packer/remnux/remnux.pkr.hcl
	vagrant box add remnux boxes/remnux.box --force
	cd packer/remnux && vagrant up

convert:
	@echo "Converting OVA to VMX..."
	packer build packer/remnux/convert.pkr.hcl

clean: 
	@echo "Cleaning temporary directories..."
	rm -rf boxes/
	rm -rf temp/
	rm -rf output-remnux/
	rm -rf output-flarevm/

all: flarevm remnux
