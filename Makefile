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

all: kernel
	echo "build done"

make_build_dirs:
	@for dir in $(KERNEL_DIRS); do \
		mkdir -p $(BUILD_DIR)/$(KERNEL_DIR)/$$dir; \
	done


kernel: make_build_dirs $(CKOBJECTS)
	mkdir -p $(BUILD_DIR)/boot
	$(AS) -f bin $(ARCH_DIR)/boot/boot.asm -o $(BOOT_DIR)/boot.bin
	$(AS) -f elf $(ARCH_DIR)/boot/kentry.asm -o $(BUILD_DIR)/boot/kentry.o
	$(LD) $(BUILD_DIR)/boot/kentry.o $(CKOBJECTS) $(LDFLAGS) -o $(BOOT_DIR)/kernel.bin
	cat $(BOOT_DIR)/boot.bin $(BOOT_DIR)/kernel.bin > $(BOOT_DIR)/os.bin

$(BUILD_DIR)/%.o: %.c
#	echo $(dir $@)
#	[ ! -d "$(dir $@)" ] && mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -rf $(BUILD_DIR)/*