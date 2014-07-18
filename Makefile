.PHONY: all clean

ROOTFS ?= linaro-trusty-developer-20140522-661.tar.gz
ROOTFSURL ?= http://releases.linaro.org/14.05/ubuntu/trusty-images/developer/
BOARD ?= cubieboard2
# BOARD ?= cubietruck

all: 
	@echo ------
	@echo "make clone"
	@echo "# will fetch repositories or pull"
	@echo "make build"
	@echo "# will build xen, u-boot and linux dom0"
	@echo "make cubie.tar"
	@echo "# gives you a sparse tarfile of the image"
	@echo ------

## Fetch and clone all the external files needed
clone: $(ROOTFS)
	./clone-repos.sh
	cp config/config-cubie2 linux-sunxi/.config

build:
	./build-uboot.sh
	./build-xen.sh
	./build-linux.sh

## Get the latest Linaro root image
$(ROOTFS):
	curl -OL $(ROOTFSURL)/$(ROOTFS)

## Build the image file
cubie.img: boot/boot.scr $(ROOTFS)
	sudo env ROOTFS=$(ROOTFS) ./build.sh || (rm -f $@; exit 1)

## Make a sparse (smaller) archive of the image file
cubie.tar: cubie.img
	rm -f cubie.tar
	tar -Scf $@ $<

## Generate the u-boot boot commands script
%.scr: %.cmd.$(BOARD)
	./u-boot-sunxi/tools/mkimage -C none -A arm -T script -d "$<" "$@"
	
clean:
	rm -f cubie.img boot/boot.scr
