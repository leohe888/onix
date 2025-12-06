[org 0x1000]

dw 0x55aa; 魔数

; 打印字符串
mov si, loading
call print

xchg bx, bx

detect_momory:
    xor ebx, ebx; 将 ebx 清零

    ; ARDS 缓存地址
    mov ax, 0
    mov es, ax
    mov edi, ards_buffer

    mov edx, 0x534d4150; 签名

.next:
    mov eax, 0xe820; 功能号
    mov ecx, 20; ARDS 大小，以字节为单位
    int 0x15

    jc error; 若 CF 为 1，表示出错

    add di, cx; 改变下一个 ARDS 缓存地址

    inc word [ards_count]; 将 ARDS 数量加一

    cmp ebx, 0
    jnz .next
    
    mov si, detecting
    call print

    jmp prepare_protected_mode

prepare_protected_mode:
    xchg bx, bx

    cli; 关闭中断

    ; 打开 A20 线
    in al, 0x92
    xor al, 0b10
    out 0x92, al

    lgdt [gdt_ptr]; 加载 GDT

    ; 进入保护模式
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp code_selector:protected_mode; 用远跳转刷新流水线

print:
    mov ah, 0x0e
.next:
    mov al, [si]
    cmp al, 0
    jz .done
    int 0x10
    inc si
    jmp .next
.done:
    ret

loading:
    db "Loading Onix...", 10, 13, 0; \n\r\0

detecting:
    db "Detecting Memory Success...", 10, 13, 0; \n\r\0

error:
    mov si, .msg
    call print
    hlt
    jmp $
    .msg db "Loading Error!!!", 10, 13, 0; \n\r\0

[bits 32]
protected_mode:
    xchg bx, bx

    ; 初始化段寄存器
    mov ax, data_selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x10000; 修改栈顶

    mov byte [0xb8000], 'P'

jmp $; 阻塞

code_selector equ (1 << 3)
data_selector equ (2 << 3)

memory_base equ 0; 段基地址
memory_limit equ ((1024 * 1024 * 1024 * 4) / (1024 * 4) - 1); 段界限：4GB / 4KB - 1（粒度为 4KB）

gdt_ptr:
    dw gdt_end - gdt_base - 1; GDT 界限
    dd gdt_base; GDT 基地址

gdt_base:
    dd 0, 0; NULL 描述符
gdt_code:
    dw memory_limit & 0xffff; 段界限 0 ~ 15 位
    dw memory_base & 0xffff; 段基地址 0 ~ 16 位
    db (memory_base >> 16) & 0xff; 段基地址 16 ~ 23 位
    db 0b1_00_1_1010; P(1) DPL(00) S(1) Type(0010 - 代码段，非依从，可读，未被访问过)
    db 0b1_1_0_0_0000 | (memory_limit >> 16) & 0xf;G(1) D/B(1) L(0) AVL(0) 段界限 16 ~ 19 位
    db (memory_base >> 24) & 0xff; 段基地址 24 ~ 31 位
gdt_data:
    dw memory_limit & 0xffff; 段界限 0 ~ 15 位
    dw memory_base & 0xffff; 段基地址 0 ~ 16 位
    db (memory_base >> 16) & 0xff; 段基地址 16 ~ 23 位
    db 0b1_00_1_0010; P(1) DPL(00) S(1) Type(0010 - 数据段，向上扩展，可写，未被访问过)
    db 0b1_1_0_0_0000 | (memory_limit >> 16) & 0xf;G(1) D/B(1) L(0) AVL(0) 段界限 16 ~ 19 位
    db (memory_base >> 24) & 0xff; 段基地址 24 ~ 31 位
gdt_end:

ards_count:
    dw 0
ards_buffer:
