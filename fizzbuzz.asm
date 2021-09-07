extern printf

section .data
fizz: db "Fizz", 0
buzz: db "Buzz", 0
ir: db "%d", 0
nl: db 10, 0

section .text
global main
main:
    mov rax, 1

loopr:
    cmp rax, 101
    jge end

    push rax
    xor rdx, rdx
    mov rcx, 3
    idiv rcx
    pop rax
    cmp rdx, 0
    je afizz

    push rax
    xor rdx, rdx
    mov rcx, 5
    idiv rcx
    pop rax
    cmp rdx, 0
    je abuzz

    push rax
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov rcx, ir
    mov rdx, rax
    call printf
    add rsp, 32
    mov rsp, rbp
    pop rbp
    pop rax
    
    jmp line

afizz:
    push rax
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov rcx, fizz
    call printf
    add rsp, 32
    mov rsp, rbp
    pop rbp
    pop rax
    
    push rax
    xor rdx, rdx
    mov rcx, 5
    idiv rcx
    pop rax
    cmp rdx, 0
    je abuzz
    
    jmp line

abuzz:
    push rax
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov rcx, buzz
    call printf
    add rsp, 32
    mov rsp, rbp
    pop rbp
    pop rax

    jmp line

line:
    push rax
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov rcx, nl
    call printf
    add rsp, 32
    mov rsp, rbp
    pop rbp
    pop rax

    inc rax
    jmp loopr

end:
    ret