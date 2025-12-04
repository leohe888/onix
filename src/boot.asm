[org 0x7c00]

; 设置屏幕模式为文本模式，清除屏幕
mov ax, 3
int 0x10

; 初始化段寄存器
mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00

mov si, booting
call print

xchg bx, bx; bochs 魔数断点

mov edi, 0x1000; 目标地址
mov ecx, 0; 起始扇区
mov bl, 1; 扇区数量

call read_disk

xchg bx, bx; bochs 魔数断点

mov edi, 0x1000; 目标地址
mov ecx, 2; 起始扇区
mov bl, 1; 扇区数量
call write_disk

xchg bx, bx; bochs 魔数断点

; 阻塞
jmp $
read_disk:
    ; 设置读写扇区的数量
    mov dx, 0x1f2
    mov al, bl
    out dx, al

    ; 设置 LBA 的 0-7 位
    inc dx; 0x1f3
    mov al, cl
    out dx, al

    ; 设置 LBA 的 8-15 位
    inc dx; 0x1f4
    shr ecx, 8
    mov al, cl
    out dx, al

    ; 设置 LBA 的 16-23 位
    inc dx; 0x1f5
    shr ecx, 8
    mov al, cl
    out dx, al

    ; 设置寻址模式，驱动器，以及 LBA 的 24-27 位
    inc dx; 0x1f6
    shr ecx, 8
    and cl, 0b1111; 将高四位置为 0
    mov al, 0b1110_0000; LBA 模式，主盘
    or al, cl
    out dx, al

    inc dx; 0x1f7
    mov al, 0x20; 读命令
    out dx, al

    xor ecx, ecx; 将 ecx 清零
    mov cl, bl; 将扇区数存入 cl

    .read:
        push cx; 保存 cx
        call .waits; 等待数据准备完毕
        call .reads; 读取一个扇区
        pop cx; 恢复 cx
        loop .read

    ret

    .waits:
        mov dx, 0x1f7
        .check:
            in al, dx

            ; 一点点延迟
            jmp $ + 2
            jmp $ + 2
            jmp $ + 2

            and al, 0b1000_1000
            cmp al, 0b0000_1000
            jnz .check
        ret
    
    .reads:
        mov dx, 0x1f0
        mov cx, 256; 一个扇区 256 个字
        .readw:
            in ax, dx

            ; 一点点延迟
            jmp $ + 2
            jmp $ + 2
            jmp $ + 2

            mov [edi], ax
            add edi, 2
            loop .readw
        ret

write_disk:
    ; 设置读写扇区的数量
    mov dx, 0x1f2
    mov al, bl
    out dx, al

    ; 设置 LBA 的 0-7 位
    inc dx; 0x1f3
    mov al, cl
    out dx, al

    ; 设置 LBA 的 8-15 位
    inc dx; 0x1f4
    shr ecx, 8
    mov al, cl
    out dx, al

    ; 设置 LBA 的 16-23 位
    inc dx; 0x1f5
    shr ecx, 8
    mov al, cl
    out dx, al

    ; 设置寻址模式，驱动器，以及 LBA 的 24-27 位
    inc dx; 0x1f6
    shr ecx, 8
    and cl, 0b1111; 将高四位置为 0
    mov al, 0b1110_0000; LBA 模式，主盘
    or al, cl
    out dx, al

    inc dx; 0x1f7
    mov al, 0x30; 写命令
    out dx, al

    xor ecx, ecx; 将 ecx 清零
    mov cl, bl; 将扇区数存入 cl

    .write:
        push cx; 保存 cx
        call .writes; 写入一个扇区
        call .waits; 等待硬盘繁忙结束
        pop cx; 恢复 cx
        loop .write

    ret

    .waits:
        mov dx, 0x1f7
        .check:
            in al, dx

            ; 一点点延迟
            jmp $ + 2
            jmp $ + 2
            jmp $ + 2

            and al, 0b1000_0000
            cmp al, 0b0000_0000
            jnz .check
        ret
    
    .writes:
        mov dx, 0x1f0
        mov cx, 256; 一个扇区 256 个字
        .writew:
            mov ax, [edi]
            out dx, ax

            ; 一点点延迟
            jmp $ + 2
            jmp $ + 2
            jmp $ + 2
            add edi, 2
            loop .writew
        ret

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

booting:
    db "Booting Onix...", 10, 13, 0; \n\r\0

; 将剩余的空间填充为 0
times 510 - ($ - $$) db 0

; 主引导扇区的最后两个字节必须是 0x55 和 0xaa
db 0x55, 0xaa   ; 或者 dw 0xaa55