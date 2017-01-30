
SRC = $(CURDIR)/src
BUILD = $(CURDIR)/build
INC = $(CURDIR)/include

export

SRCFILES := $(shell find $(1) -type f -name '*.c' -or -name "*.py" -or -name "*.ld" -or -name "*.S" -or -name "*.h")

drive: writedisk.py
	$(MAKE) -C $(SRC)
	cd $(BUILD)
	$(TOP)/writedisk.py bootblock bootblock.o boot.elf

os.iso: $(call SRCFILES, src/kern)
	$(MAKE) -C src/kern kernel
	rm -rf isofiles
	mkdir isofiles
	mkdir isofiles/boot
	mkdir isofiles/boot/grub
	cp grub.cfg isofiles/boot/grub
	cp src/kern/kernel isofiles/boot
	grub-mkrescue -d deps/i386-pc -o os.iso isofiles
	rm -rf isofiles

qemu: drive
	qemu-system-x86_64 -drive file=bootblock,index=0,media=disk,format=raw,index=0

qemu-grub: os.iso
	qemu-system-x86_64 -cdrom os.iso

clean:
	$(MAKE) -C src/kern clean
	$(MAKE) -C src/boot clean
	rm -rf os.iso
