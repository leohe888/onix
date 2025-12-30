# ELF

ELF（Executable and Linkable Format，可执行与可链接格式）是一种标准化的二进制文件格式，其主要类型包括：

- 可执行文件（Executable File）
- 可重定位文件（Relocatable File）或目标文件（Object File）—— .o
- 共享目标文件（Shared Object File）或动态链接库（Dynamic Link Library）—— .so
- 核心转储文件（Core Dump File）

> 为了节省磁盘空间，Linux 默认将核心转储文件的大小限制设为 0，即禁用核心转储功能。可以使用 `ulimit -c` 命令查看核心转储文件的大小限制，使用 `ulimit -c unlimited` 命令临时解除核心转储文件大小的限制。

ELF 文件通常包含以下几个部分：

- ELF 头（ELF Header）：描述文件的基本信息。必须有。
- 程序头表（Program Header Table）：描述文件中的各个段。可执行文件和共享目标文件必须有，可重定位文件通常没有，也不需要。
- 节（Section）：对不同类型内容的逻辑划分，每一节保存一种“同类信息”。必须有若干核心节。
- 节头表（Section Header Table）：描述文件中的各个节。可重定位文件必须有，可执行文件和共享目标文件可以没有。

> 一个段通常由一个或多个节组成。节是链接时的概念，段是运行时的概念。

```text
+------------------------+
| ELF Header             |
+------------------------+
| Program Header Table   |
+------------------------+
| Sections               |
|  .text                 |
|  .data                 |
|  .bss                  |
|  .rodata               |
|  .symtab               |
|  .strtab               |
|  .shstrtab             |
|  ...                   |
+------------------------+
| Section Header Table   |
+------------------------+
```

可以通过 `man elf` 命令查看 ELF 文件格式的详细说明。头文件 `/usr/include/elf.h` 中定义了 ELF 文件格式的相关结构体和宏。

## ELF 头

```c
// 32 位
typedef struct  /* 共 52 字节 */
{
  unsigned char e_ident[16];  // 魔数与其他信息
  uint16_t      e_type;       // 目标文件类型
  uint16_t      e_machine;    // 架构
  uint32_t      e_version;    // 目标文件版本
  uint32_t      e_entry;      // 入口点虚拟地址
  uint32_t      e_phoff;      // 程序头表文件偏移
  uint32_t      e_shoff;      // 节头表文件偏移
  uint32_t      e_flags;      // 处理器特定标志
  uint16_t      e_ehsize;     // ELF 头大小
  uint16_t      e_phentsize;  // 程序头表条目大小
  uint16_t      e_phnum;      // 程序头表条目数量
  uint16_t      e_shentsize;  // 节头表条目大小
  uint16_t      e_shnum;      // 节头表条目数量
  uint16_t      e_shstrndx;   // .shstrtab 节在节头表中的索引
} Elf32_Ehdr;

// 64 位
typedef struct {  /* 共 64 字节 */
    unsigned char e_ident[16]; // 魔数与其他信息
    uint16_t      e_type;      // 目标文件类型
    uint16_t      e_machine;   // 架构
    uint32_t      e_version;   // 目标文件版本
    uint64_t      e_entry;     // 入口点虚拟地址
    uint64_t      e_phoff;     // 程序头表文件偏移
    uint64_t      e_shoff;     // 节头表文件偏移
    uint32_t      e_flags;     // 处理器特定标志
    uint16_t      e_ehsize;    // ELF 头大小
    uint16_t      e_phentsize; // 程序头表条目大小
    uint16_t      e_phnum;     // 程序头表条目数量
    uint16_t      e_shentsize; // 节头表条目大小
    uint16_t      e_shnum;     // 节头表条目数量
    uint16_t      e_shstrndx;  // .shstrtab 节在节头表中的索引
} Elf64_Ehdr;
```

## 程序头

```c
// 32 位
typedef struct
{
  uint32_t p_type;    // 段类型
  uint32_t p_offset;  // 段文件偏移
  uint32_t p_vaddr;   // 段虚拟地址
  uint32_t p_paddr;   // 段物理地址
  uint32_t p_filesz;  // 段在文件中的大小
  uint32_t p_memsz;   // 段在内存中的大小
  uint32_t p_flags;   // 段标志
  uint32_t p_align;   // 段对齐
} Elf32_Phdr;


// 64 位
typedef struct
{
  uint32_t p_type;    // 段类型
  uint32_t p_flags;   // 段标志
  uint64_t p_offset;  // 段文件偏移
  uint64_t p_vaddr;   // 段虚拟地址
  uint64_t p_paddr;   // 段物理地址
  uint64_t p_filesz;  // 段在文件中的大小
  uint64_t p_memsz;   // 段在内存中的大小
  uint64_t p_align;   // 段对齐
} Elf64_Phdr;
```

## 节

- `.text`：
  存储可执行代码。

- `.data`：
  存储已初始化的全局变量和静态变量。

- `.bss`：
  存储未初始化的全局变量和静态变量。不占用磁盘空间，在程序运行时分配内存。

- `.rodata`：
  存储只读数据，如字符串常量。

- `.symtab`：
  存储函数名、变量名等符号信息。可被 `strip` 删除。

  ```c
  // 32 位
  typedef struct  /* 共 16 字节 */
  {
    uint32_t      st_name;  // 符号名（在 .strtab 节中的索引）
    uint32_t      st_value; // 符号值
    uint32_t      st_size;  // 符号大小
    unsigned char st_info;  // 符号类型和绑定
    unsigned char st_other; // 符号可见性
    uint16_t      st_shndx; // 节索引
  } Elf32_Sym;

  // 64 位
  typedef struct  /* 共 24 字节 */
  {
    uint32_t      st_name;  // 符号名（在 .strtab 节中的索引）
    unsigned char st_info;  // 符号类型和绑定
    unsigned char st_other; // 符号可见性
    uint16_t      st_shndx; // 节索引
    uint64_t      st_value; // 符号值
    uint64_t      st_size;  // 符号大小
  } Elf64_Sym;
  ```

- `.strtab`：
  存储 `.symtab` 使用的字符串。

- `.shstrtab`：
  存储节名。

- 重定位节：
  - `.rel.text` / `.rela.text`：
    存储 `.text` 节的重定位信息。

  - `.rel.data` / `.rela.data`：
    存储 `.data` 节的重定位信息。
  
  相对寻址重定位：`重定位值 = 符号地址 - 重定位位置地址 + 加数`。一般用于函数调用、条件跳转等。
  绝对寻址重定位：`重定位值 = 符号地址 + 加数`。一般用于全局变量、函数指针等。

  ```c
  // 32 位
  typedef struct  /* 共 8 字节 */
  {
    uint32_t  r_offset; // 地址
    uint32_t  r_info;   // 重定位类型和符号索引
  } Elf32_Rel;

  // 64 位
  typedef struct  /* 共 16 字节 */
  {
    uint64_t  r_offset; // 地址
    uint64_t  r_info;   // 重定位类型和符号索引
  } Elf64_Rel;

  typedef struct  /* 共 12 字节 */
  {
    uint32_t  r_offset; // 地址
    uint32_t  r_info;   // 重定位类型和符号索引
    int32_t   r_addend; // 加数
  } Elf32_Rela;

  typedef struct  /* 共 24 字节 */
  {
    uint64_t  r_offset; // 地址
    uint64_t  r_info;   // 重定位类型和符号索引
    int64_t   r_addend; // 加数
  } Elf64_Rela;
  ```

- `.interp`：
  存储动态链接器的路径。

- `.dynamic`：
  存储动态链接信息。

- `.got` / `.got.plt` / `.plt`：
  存储全局偏移表（Global Offset Table，GOT）和过程链接表（Procedure Linkage Table，PLT）。`.got` 存储存储全局变量的真实内存地址，`.got.plt` 存储外部函数的真实内存地址，`.plt` 存储外部函数的跳转代码。每个外部函数对应一个独立的 PLT 条目。首次调用外部函数时，触发动态链接器解析符号真实地址，并将地址写入 GOT 对应条目。后续调用外部函数时，直接跳转到 GOT 中已缓存的真实地址，提升执行效率。而对于全局变量，需要在程序启动时由动态链接器直接将其真实地址写入 GOT 对应条目。

- `.init` / `.fini`：
  存储程序初始化和终止时的代码（由编译器自动生成）。

- `.comment`：
  存储编译器版本信息。

- `.eh_frame` / `.eh_frame_hdr`：
  存储异常处理信息。

- `.debug_*`：
  存储调试信息。

- `.note.*`：
  存储附加信息。

## 节头

```c
// 32 位
typedef struct  /* 共 40 字节 */
{
  uint32_t  sh_name;      // 节名（在 .shstrtab 节中的索引）
  uint32_t  sh_type;      // 节类型
  uint32_t  sh_flags;     // 节标志
  uint32_t  sh_addr;      // 节在运行时的虚拟地址
  uint32_t  sh_offset;    // 节文件偏移
  uint32_t  sh_size;      // 节大小
  uint32_t  sh_link;      // 链接到其他节的索引
  uint32_t  sh_info;      // 附加的节信息
  uint32_t  sh_addralign; // 节对齐
  uint32_t  sh_entsize;   // 若节包含表，则为表项大小
} Elf32_Shdr;

// 64 位
typedef struct  /* 共 64 字节 */
{
  uint32_t  sh_name;      // 节名（在 .shstrtab 节中的索引）
  uint32_t  sh_type;      // 节类型
  uint64_t sh_flags;      // 节标志
  uint64_t  sh_addr;      // 节在运行时的虚拟地址
  uint64_t   sh_offset;   // 节文件偏移
  uint64_t sh_size;       // 节大小
  uint32_t  sh_link;      // 链接到其他节的索引
  uint32_t  sh_info;      // 附加的节信息
  uint64_t sh_addralign;  // 节对齐
  uint64_t sh_entsize;    // 若节包含表，则为表项大小
} Elf64_Shdr;
```

## 常用工具

### readelf

- `-h`：查看 ELF 头。
- `-S`：查看节头表。
- `-l`：查看程序头表。
- `-e`：等价于 `-h -S -l`。
- `-s`：查看符号表。
- `-r`：查看重定位表。
- `-p <节名称/节索引>`：以字符串的形式查看节的内容。

### objdump

- `-h`：查看节头表。
- `-t`：查看符号表。
- `-d`：反汇编可执行节。
- `-D`：反汇编所有节。
- `-s`：以十六进制 +  ASCII 字符的形式显示所有节的内容。
- `-S`：将汇编代码和源代码关联起来显示。`-S` 仅负责 “关联源码”，需要配合 `-D` 或 `-d` 使用。需要使用 `-g` 选项来生成调试信息，否则无法关联源码。
- `-j <节名称>`：仅显示指定节的内容。

### file

查看文件类型。

### nm

查看符号表。

### ldd

查看依赖的动态链接库。
