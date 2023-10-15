CC := i686-elf-gcc
LD := i686-elf-ld
AS := nasm
CFLAGS := -ffreestanding -nostdlib -m32 -c -I./kernel/include
LDFLAGS := -e 0x10000 --oformat binary
ARCH := i386
ARCH_DIR := arch/$(ARCH)

BUILD_DIR := build
KERNEL_DIR := kernel/kernel
BOOT_DIR := boot

KERNEL_DIRS := init

CKSOURCES := $(foreach DIR, $(KERNEL_DIRS), $(wildcard $(KERNEL_DIR)/$(DIR)/*.c))
#ASMSOURCES :=

CKOBJECTS := $(patsubst %.c, $(BUILD_DIR)/%.o, $(CKSOURCES))

#$(BUILD_DIR)/

all: make_build_dirs bootloader kernel
	cat $(BOOT_DIR)/boot.bin $(BOOT_DIR)/kernel.bin > $(BOOT_DIR)/os.bin
	@echo "build done"

make_build_dirs:
	@for dir in $(KERNEL_DIRS); do \
		mkdir -p $(BUILD_DIR)/$(KERNEL_DIR)/$$dir; \
	done

bootloader:
	mkdir -p $(BUILD_DIR)/boot
	$(AS) -f bin $(ARCH_DIR)/boot/boot.asm -o $(BOOT_DIR)/boot.bin


kernel: make_build_dirs $(CKOBJECTS)
	$(LD) $(CKOBJECTS) $(LDFLAGS) -o $(BOOT_DIR)/kernel.bin


$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS) $< -o $@

floppy: all
	dd if=$(BOOT_DIR)/os.bin of=$(BOOT_DIR)/floppy.img bs=512 count=2880

clean:
	rm -rf $(BUILD_DIR)/*
	rm -rf $(BOOT_DIR)/*