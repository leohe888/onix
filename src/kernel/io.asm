[bits 32]

section .text

global inb
inb:
    push ebp
    mov ebp, esp

    xor eax, eax        ; 将 eax 清零
    mov edx, [ebp + 8]  ; port

    in al, dx           ; 从端口读取一个字节

    ; 一点点延迟
    jmp $ + 2
    jmp $ + 2
    jmp $ + 2

    leave
    ret

global outb
outb:
    push ebp
    mov ebp, esp

    mov edx, [ebp + 8]  ; port
    mov eax, [ebp + 12] ; data

    out dx, al          ; 将一个字节写入端口

    ; 一点点延迟
    jmp $ + 2
    jmp $ + 2
    jmp $ + 2

    leave
    ret

global inw
inw:
    push ebp
    mov ebp, esp

    xor eax, eax        ; 将 eax 清零
    mov edx, [ebp + 8]  ; port

    in ax, dx           ; 从端口读取一个字

    ; 一点点延迟
    jmp $ + 2
    jmp $ + 2
    jmp $ + 2

    leave
    ret

global outw
outw:
    push ebp
    mov ebp, esp

    mov edx, [ebp + 8]  ; port
    mov eax, [ebp + 12] ; data

    out dx, ax          ; 将一个字写入端口

    ; 一点点延迟
    jmp $ + 2
    jmp $ + 2
    jmp $ + 2

    leave
    ret
