BUILD := ../build
SRC := .

MULTIBOOT2:=0x10000
ENTRYPOINT:=$(shell python3 -c "print(f'0x{$(MULTIBOOT2) + 64:x}')")

CFLAGS := -m32					# 生成 32 位代码
CFLAGS += -fno-builtin			# 不使用 GCC 内建函数
CFLAGS += -nostdinc				# 不使用标准头文件
CFLAGS += -fno-pic				# 不生成位置无关代码
CFLAGS += -fno-pie				# 不生成位置无关可执行文件
CFLAGS += -nostdlib				# 不使用标准库
CFLAGS += -fno-stack-protector	# 不使用栈保护
CFLAGS := $(strip $(CFLAGS))	# 去掉多余的空格

DEBUG := -g						# 生成调试信息
INCLUDE := -I$(SRC)/include		# 包含头文件目录

$(BUILD)/boot/%.bin: $(SRC)/boot/%.asm
	$(shell mkdir -p $(dir $@))
	nasm -f bin $< -o $@

$(BUILD)/%.o: $(SRC)/%.asm
	$(shell mkdir -p $(dir $@))
	nasm -f elf32 $(DEBUG) $< -o $@

$(BUILD)/%.o: $(SRC)/%.c
	$(shell mkdir -p $(dir $@))
	gcc $(CFLAGS) $(DEBUG) $(INCLUDE) -c $< -o $@

LDFLAGS:= -m elf_i386 \
		-static \
		-Ttext $(ENTRYPOINT)\
		--section-start=.multiboot2=$(MULTIBOOT2)
LDFLAGS:=$(strip ${LDFLAGS})

$(BUILD)/kernel.bin: \
	$(BUILD)/kernel/start.o \
	$(BUILD)/kernel/main.o \
	$(BUILD)/kernel/io.o \
	$(BUILD)/kernel/device.o \
	$(BUILD)/kernel/console.o \
	$(BUILD)/kernel/printk.o \
	$(BUILD)/kernel/assert.o \
	$(BUILD)/kernel/debug.o \
	$(BUILD)/kernel/global.o \
	$(BUILD)/kernel/task.o \
	$(BUILD)/kernel/thread.o \
	$(BUILD)/kernel/mutex.o \
	$(BUILD)/kernel/gate.o \
	$(BUILD)/kernel/schedule.o \
	$(BUILD)/kernel/interrupt.o \
	$(BUILD)/kernel/handler.o \
	$(BUILD)/kernel/clock.o \
	$(BUILD)/kernel/time.o \
	$(BUILD)/kernel/rtc.o \
	$(BUILD)/kernel/ide.o \
	$(BUILD)/kernel/memory.o \
	$(BUILD)/kernel/arena.o \
	$(BUILD)/kernel/keyboard.o \
	$(BUILD)/kernel/buffer.o \
	$(BUILD)/fs/super.o \
	$(BUILD)/lib/bitmap.o \
	$(BUILD)/lib/list.o \
	$(BUILD)/lib/fifo.o \
	$(BUILD)/lib/string.o \
	$(BUILD)/lib/vsprintf.o \
	$(BUILD)/lib/stdlib.o \
	$(BUILD)/lib/syscall.o \
	$(BUILD)/lib/printf.o \

	$(shell mkdir -p $(dir $@))
	ld ${LDFLAGS} $^ -o $@

$(BUILD)/system.bin: $(BUILD)/kernel.bin
	objcopy -O binary $< $@

$(BUILD)/system.map: $(BUILD)/kernel.bin
	nm $< | sort > $@

include utils/image.mk
include utils/cdrom.mk
include utils/cmd.mk

.PHONY: clean
clean:
	rm -rf $(BUILD)