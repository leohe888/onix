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

    ; 签名
    mov edx, 0x534d4150

.next:
    ; 功能号
    mov eax, 0xe820

    ; ARDS 大小，以字节为单位
    mov ecx, 20

    int 0x15

    ; 若 CF 为 1，表示出错
    jc error

    ; 改变下一个 ARDS 缓存地址
    add di, cx

    ; 将 ARDS 数量加一
    inc word [ards_count]

    cmp ebx, 0
    jnz .next
    
    mov si, detecting
    call print

    xchg bx, bx

; 阻塞
jmp $

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


ards_count:
    dw 0
ards_buffer:
