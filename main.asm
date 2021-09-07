%include "stdfunc.asm"

section .data
msg: db "Hello", 0
stri: db "-785", 0

section .text
global main
main:
    mov rcx, stri
    call atoi
    mov rcx, rax
    call printi

    mov rcx, 0
    call exit