%include "array.asm"

section .data
msg: db "Hello", 0
stri: db "-785", 0

section .bss
arr: resb 7

section .text
global main
main:
    mov rcx, arr
    mov rdx, 2
    mov r8, 8
    call array

    push rcx
    call array.len
    mov rcx, rax
    call printi
    pop rcx
    call printnl

    mov rdx, 0
    mov r8, 1
    call array.set

    mov rdx, 1
    mov r8, 0
    call array.set

    call array.print

    mov rcx, 0
    call exit