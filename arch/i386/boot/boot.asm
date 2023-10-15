[bits 16]
[org 0x7c00]

mov ah, 0x00
mov al, 0x03
int 0x10

mov bx, boot_msg
mov ah, 0x0e
mov al, [bx]
boot_msg_loop:
    int 0x10
    inc bx
    mov al, [bx]
    test al, al
    jnz boot_msg_loop


mov ax, 0x1000
mov es, ax
xor bx, bx

mov ah, 0x02
mov al, 1
mov ch, 0
mov cl, 2
mov dh, 0
int 0x13


mov ah, 1
int 0x13
test ah, ah
jnz disk_read_error

cli

xor ax, ax
mov ds, ax

lgdt [gdtr]
mov eax, cr0
or al, 1
mov cr0, eax

jmp 0x08:protected_mode


protected_mode:
    [bits 32]
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x105000 
    jmp 0x10000


gdt_start:
null_descriptor:
    dq 0
code_descriptor:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00
data_descriptor:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdtr:
    dw gdtr-gdt_start-1
    dd gdt_start

disk_read_error:
    [bits 16]
    push ax
    mov bx, disk_error_msg
    mov ah, 0x0e
    mov al, [bx]
disk_error_msg_loop:
    int 0x10
    inc bx
    mov al, [bx]
    test al, al
    jnz disk_error_msg_loop

    pop ax
    push ax

    shr ax, 4
    and ax, 0x0f
    add al, 'A'
    mov ah, 0x0e
    int 0x10

    pop ax
    mov al, ah
    and ax, 0x0f
    add al, 'A'
    mov ah, 0x0e
    int 0x10

    jmp $
    


boot_msg db "Booting LopataOS v3...", 0
disk_error_msg db "Failed to read from disk! Error code: ", 0

times 510-($-$$) db 0
db 0x55, 0xaa