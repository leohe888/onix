CFLAGS := -m32					# 生成 32 位代码
# CFLAGS += -fno-builtin			# 不使用 GCC 内建函数
# CFLAGS += -nostdinc				# 不使用标准头文件
# CFLAGS += -fno-pic				# 不生成位置无关代码
# CFLAGS += -fno-pie				# 不生成位置无关可执行文件
# CFLAGS += -nostdlib				# 不使用标准库
# CFLAGS += -fno-stack-protector	# 不使用栈保护
CFLAGS := $(strip $(CFLAGS))	# 去掉多余的空格

.PHONY: hello.s
hello.s: hello.c
	gcc $(CFLAGS) -S $< -o $@
