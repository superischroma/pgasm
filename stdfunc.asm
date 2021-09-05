extern GetStdHandle
extern WriteFile
extern ExitProcess

section .data
nl: db 10, 0
TRUE: equ 1
FALSE: equ 0
truestr: db "true", 0
falsestr: db "false", 0

section .bss
outh: resq 1 ; cache for stdout handle so we only need to call GetStdHandle once
pibuf: resb 16 ; buffer for numerical chars when printing out an integer

section .text

; prints(rcx: string) -> void
prints:
    push rbp ; preserve stack frame
    mov rbp, rsp ; 
    push 0
    sub rsp, 32
    call stdout ; grab stdout handle
    push rax ; push the handle to the stack
    call strlen ; get the length of the string
    mov rdx, rcx ; move our string into rdx
    pop rcx ; put our pushed rax value into rcx
    mov r8, rax ; move length into r8
    mov r9, rsp ; whatever this is
    call WriteFile ; call function
    add rsp, 32
    mov rsp, rbp
    pop rbp
    ret

; printi(rcx: int) -> void
printi:
    push rax
    push rbx
    push r8
    push r9
    mov rbx, 15 ; reverse counter
    cmp rcx, 0
    jl .printin
    mov r9, FALSE
    jmp .printil

.printin:
    imul rcx, -1
    mov r9, TRUE

.printil:
    mov rdx, 0
    mov rax, rcx
    mov r8, 10
    idiv r8
    mov rcx, rax
    add rdx, 48

    mov rax, pibuf
    add rax, rbx
    mov byte [rax], dl

    cmp rcx, 0
    je .printinc
    dec rbx
    jmp .printil

.printinc:
    cmp r9, TRUE ; is value negative?
    je .printinu
    jmp .printip

.printinu:
    mov rdx, 45 ; negative sign

    dec rbx

    mov rax, pibuf
    add rax, rbx
    mov byte [rax], dl

.printip:
    push rbp
    mov rbp, rsp
    push 0
    sub rsp, 32
    call stdout
    mov rcx, rax

    mov rdx, pibuf
    add rdx, rbx

    mov r8, 15
    sub r8, rbx
    inc r8
    mov r9, rsp
    call WriteFile
    add rsp, 32
    mov rsp, rbp
    pop rbp

    pop r9
    pop r8
    pop rbx
    pop rax
    ret

; printb(rcx: bool) -> void
printb:
    cmp rcx, 1
    jl .printbn
    mov rcx, truestr
    call prints
    ret

.printbn:
    mov rcx, falsestr
    call prints
    ret

; printnl() -> void
printnl:
    push rcx
    mov rcx, nl
    call prints
    pop rcx
    ret

; strlen(rcx: string) -> rax: int
strlen:
    push rcx ; make sure stringp is not modified by the end
    mov rax, 0 ; counter in rax
    jmp .strlenl

.strlenl:
    cmp byte [rcx], 0 ; is byte at rbx a null byte?
    je .strlene ; if so, end
    inc rcx ; otherwise, increment address at rbx
    inc rax ; and increment counter
    jmp .strlenl

.strlene:
    pop rcx ; 
    ret

; stdout() -> rax: long
stdout:
    push rbx
    mov rbx, outh
    cmp qword [rbx], 0
    jne .stdoutg
    pop rbx

    push rcx
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov rcx, -11
    call GetStdHandle
    add rsp, 32
    mov rsp, rbp
    pop rbp
    pop rcx

    push rbx
    mov rbx, outh
    mov qword [rbx], rax
    pop rbx
    ret

.stdoutg:
    mov rax, qword [rbx]
    pop rbx
    ret

; exit(rcx?: int) -> void
exit:
    call ExitProcess
    ret