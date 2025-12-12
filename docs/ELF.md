# ELF

可执行与可链接格式（Executable and Linkable Format，ELF）是一种常见的二进制文件格式，其主要类型包括：

- 可执行文件
- 可重定位文件或目标文件（.o）
- 共享目标文件或动态链接库（.so）
- 核心转储文件

ELF 文件通常由以下部分组成：

```text
+-------------------------+
|      ELF Header         |
+-------------------------+
|   Program Header Table  |
+-------------------------+
|      Sections...        |
+-------------------------+
|   Section Header Table  |
+-------------------------+
```

节是链接时的概念，段是执行时的概念。一个段通常由一个或多个节组成。

## ELF 头

- e_ident：ELF 魔数和其他信息（16字节）。
  - e_ident[0] ~ e_ident[3]：ELF 魔数。固定为 0x7f，'E'，'L'，'F'。
  - e_ident[4]：文件类别。1 表示 32 位，2 表示 64 位。
  - e_ident[5]：数据编码（字节序）。1 表示小端，2 表示大端。
  - e_ident[6]：ELF 版本。通常为 1，表示当前版本。
  - e_ident[7]：操作系统 ABI。0 表示 System V，3 表示 Linux，6 表示 Solaris，9 表示 FreeBSD，97 表示 ARM。
  - e_ident[8]：ABI 版本。取决于操作系统 ABI。
  - e_ident[9] ~ e_ident[15]：保留，通常为 0。
- e_type：文件类型（2 字节）。1 表示可重定位文件，2 表示可执行文件，3 表示共享目标文件，4 表示核心转储文件。
- e_machine：目标架构（2 字节）。3 表示 x86，62 表示 x86_64，40 表示 ARM 32 位，183 表示 ARM 64 位。
- e_version：ELF 版本（4 字节）。通常为 1，表示当前版本。
- e_entry：入口点地址（4 字节或 8 字节）。
- e_phoff：程序头表文件偏移量（4 字节或 8 字节）。如果文件没有程序头表，则为 0。
- e_shoff：节头表文件偏移量（4 字节或 8 字节）。如果文件没有节头表，则为 0。
- e_flags：处理器特定标志（4 字节）。对于大多数架构，此字段为 0。
- e_ehsize：ELF 头大小（2 字节）。以字节为单位。32 位 ELF 通常为 52 字节，64 位 ELF 通常为 64 字节。
- e_phentsize：程序头表条目大小（2 字节）。以字节为单位。32 位 ELF 通常为 32 字节，64 位 ELF 通常为 56 字节。
- e_phnum：程序头表条目数量（2 字节）。如果文件没有程序头表，则为 0。
- e_shentsize：节头表条目大小（2 字节）。以字节为单位。32 位 ELF 通常为 40 字节，64 位 ELF 通常为 64 字节。
- e_shnum：节头表条目数量（2 字节）。如果文件没有节头表，则为 0。
- e_shstrndx：节头字符串表索引（2 字节）。节头字符串表（.shstrtab）在节头表中的索引。此表包含所有节名称的字符串。

```c
// 32 位
typedef struct
{
  unsigned char e_ident[16];  /* Magic number and other info */
  uint16_t      e_type;       /* Object file type */
  uint16_t      e_machine;    /* Architecture */
  uint32_t      e_version;    /* Object file version */
  uint32_t      e_entry;      /* Entry point virtual address */
  uint32_t      e_phoff;      /* Program header table file offset */
  uint32_t      e_shoff;      /* Section header table file offset */
  uint32_t      e_flags;      /* Processor-specific flags */
  uint16_t      e_ehsize;     /* ELF header size in bytes */
  uint16_t      e_phentsize;  /* Program header table entry size */
  uint16_t      e_phnum;      /* Program header table entry count */
  uint16_t      e_shentsize;  /* Section header table entry size */
  uint16_t      e_shnum;      /* Section header table entry count */
  uint16_t      e_shstrndx;   /* Section header string table index */
} Elf32_Ehdr;

// 64 位
typedef struct {
    unsigned char e_ident[16]; /* Magic number and other info */
    uint16_t      e_type;      /* Object file type */
    uint16_t      e_machine;   /* Architecture */
    uint32_t      e_version;   /* Object file version */
    uint64_t      e_entry;     /* Entry point virtual address */
    uint64_t      e_phoff;     /* Program header table file offset */
    uint64_t      e_shoff;     /* Section header table file offset */
    uint32_t      e_flags;     /* Processor-specific flags */
    uint16_t      e_ehsize;    /* ELF header size in bytes */
    uint16_t      e_phentsize; /* Program header table entry size */
    uint16_t      e_phnum;     /* Program header table entry count */
    uint16_t      e_shentsize; /* Section header table entry size */
    uint16_t      e_shnum;     /* Section header table entry count */
    uint16_t      e_shstrndx;  /* Section header string table index */
} Elf64_Ehdr;
```

## 节头表

```c
// 32 位
typedef struct
{
  uint32_t  sh_name;      /* Section name (string tbl index) */
  uint32_t  sh_type;      /* Section type */
  uint32_t  sh_flags;     /* Section flags */
  uint32_t  sh_addr;      /* Section virtual addr at execution */
  uint32_t  sh_offset;    /* Section file offset */
  uint32_t  sh_size;      /* Section size in bytes */
  uint32_t  sh_link;      /* Link to another section */
  uint32_t  sh_info;      /* Additional section information */
  uint32_t  sh_addralign; /* Section alignment */
  uint32_t  sh_entsize;   /* Entry size if section holds table */
} Elf32_Shdr;

// 64 位
typedef struct
{
  uint32_t  sh_name;      /* Section name (string tbl index) */
  uint32_t  sh_type;      /* Section type */
  uint64_t sh_flags;      /* Section flags */
  uint64_t  sh_addr;      /* Section virtual addr at execution */
  uint64_t   sh_offset;   /* Section file offset */
  uint64_t sh_size;       /* Section size in bytes */
  uint32_t  sh_link;      /* Link to another section */
  uint32_t  sh_info;      /* Additional section information */
  uint64_t sh_addralign;  /* Section alignment */
  uint64_t sh_entsize;    /* Entry size if section holds table */
} Elf64_Shdr;
```

## 程序头表

## 常用工具

### readelf

- `-h`：查看 ELF 头。
- `-S`：查看节头表。
- `-l`：查看程序头表。
- `-e`：等价于 `-h -S -l`。
- `-a`：查看所有信息。

### objdump

- `-d`：反汇编可执行节。
- `-D`：反汇编所有节。
- `-S`：与 `-d` 类似，区别在于 `-S` 会交替显示源代码行和对应的汇编代码。需要编译时加 `-g` 选项。
- `-M`：指定汇编语法。`intel` 表示 Intel 风格，`att` 表示 AT&T 风格。
- `-j`：指定节名。

### file

### nm

### ldd
