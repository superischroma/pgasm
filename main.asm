%include "stdfunc.asm"

section .data
msg: db "Hello", 0

section .text
global WinMain
WinMain:
    mov rcx, 2
    call printb
    call printnl

    mov rcx, 0
    call exit