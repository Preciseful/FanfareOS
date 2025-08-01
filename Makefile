RPI_PATH=/media/$(USER)/bootfs

ARMGNU ?= aarch64-none-elf

COPS = -Wall -O0 -ffreestanding -nostdlib -nostartfiles -mstrict-align -Ikernel -mgeneral-regs-only
CPPOPS = $(COPS) -std=c++20 -fno-exceptions -fno-rtti -Wno-write-strings
ASMOPS = -Ikernel

BUILD_DIR = build/bin
SRC_DIR = kernel

all : clean kernel8.img

setup:
	rm -rf $(RPI_PATH)/kernel*
	cp -rf config.txt $(RPI_PATH)
	mkdir $(RPI_PATH)/modules

dump:
	$(ARMGNU)-objdump -D $(BUILD_DIR)/kernel8.elf > dump

clean :
	@rm -rf $(BUILD_DIR) *.img dump

$(BUILD_DIR)/%_c.o: $(SRC_DIR)/%.c
	@mkdir -p $(@D)
	@$(ARMGNU)-gcc $(COPS) -MMD -c $< -o $@

$(BUILD_DIR)/%_cpp.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(@D)
	@$(ARMGNU)-g++ $(CPPOPS) -MMD -c $< -o $@

$(BUILD_DIR)/%_s.o: $(SRC_DIR)/%.S
	@mkdir -p $(@D)
	@$(ARMGNU)-gcc $(ASMOPS) -MMD -c $< -o $@


C_FILES = $(shell find . -type f -name "*.c" | cut -d'/' -f2-)
CPP_FILES = $(shell find . -type f -name "*.cpp" | cut -d'/' -f2-)
ASM_FILES = $(shell find . -type f -name "*.S" | cut -d'/' -f2-)

OBJ_FILES = $(C_FILES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%_c.o)
OBJ_FILES += $(CPP_FILES:$(SRC_DIR)/%.cpp=$(BUILD_DIR)/%_cpp.o)
OBJ_FILES += $(ASM_FILES:$(SRC_DIR)/%.S=$(BUILD_DIR)/%_s.o)

DEP_FILES = $(OBJ_FILES:%.o=%.d)
-include $(DEP_FILES)

kernel8.img: linker.ld $(OBJ_FILES)
	@$(ARMGNU)-ld -T linker.ld -o $(BUILD_DIR)/kernel8.elf  $(OBJ_FILES)
	@$(ARMGNU)-objcopy $(BUILD_DIR)/kernel8.elf -O binary kernel8.img
	./go_rpi.sh $(RPI_PATH)