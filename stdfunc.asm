; --- Routine Rules ---
; Arguments always follow the RCX, RDX, R8, R9, reverse stack order.
; Return values are placed in the RAX register except if the routine returns void.
; ---------------------

; --- Documentation Types ---
; string: A pointer to the first byte of a C string (a null-terminated string).
; buffer: A pointer to the first byte of any uninitialized data.
; ---------------------------

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
itoabuf: resb 65 ; buffer for numerical chars when printing out an integer

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

    mov rax, itoabuf
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

    mov rax, itoabuf
    add rax, rbx
    mov byte [rax], dl

.printip:
    push rbp
    mov rbp, rsp
    push 0
    sub rsp, 32
    call stdout
    mov rcx, rax

    mov rdx, itoabuf
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

; itoa(rcx: int, rdx: buffer) -> void
itoa:
    push rax
    push rbx
    push r8
    push r9
    mov rbx, 64 ; reverse counter
    cmp rcx, 0
    jl .itoan
    mov r9, FALSE
    jmp .itoal

.itoan:
    imul rcx, -1
    mov r9, TRUE

.itoal:
    push rdx
    mov rdx, 0
    mov rax, rcx
    mov r8, 10
    idiv r8
    mov rcx, rax
    add rdx, 48

    mov rax, itoabuf
    add rax, rbx
    mov byte [rax], dl

    pop rdx
    cmp rcx, 0
    je .itoanc
    dec rbx
    jmp .itoal

.itoanc:
    cmp r9, TRUE ; is value negative?
    je .itoanu
    mov r8, 0 ; = buffer index
    jmp .itoap

.itoanu:
    dec rbx

    push rdx
    mov rdx, 45 ; negative sign

    mov rax, itoabuf
    add rax, rbx
    mov byte [rax], dl
    mov r8, 0
    pop rdx

.itoap:
    mov rax, [itoabuf + rbx]
    lea r9, [rdx + r8] ; r9 now points towards rdx + r8 (buffer + current index in buffer)
    mov [r9], rax ;
    inc rbx
    inc r8
    ; r9 is now used as a pointer
    cmp rbx, 65 ; are we not at the highest indexed char?
    jne .itoap ; if so, loop

.itoae:
    lea r9, [rdx + r8]
    mov [r9], byte 0
    pop r9
    pop r8
    pop rbx
    pop rax
    ret

; atoi(rcx: string) -> rax: int
atoi:
    push rbx
    push rdx
    push rdi
    push rsi
    call strlen
    mov rdx, rax ; iterator
    mov rax, 0 ; final value
    mov rbx, 1 ; multiplier
    cmp byte [rcx], 45 ; is our string number negative?
    je .atoin ; if so, mark it
    mov rdi, FALSE ; otherwise, mark that it is not
    jmp .atoil ; start loop

.atoin:
    mov rdi, TRUE

.atoil:
    dec rdx
    mov rsi, 0
    mov sil, byte [rcx + rdx] ; move our current value into r9
    sub sil, 48 ; get its true value
    imul rsi, rbx ; multiply by the multiplier
    imul rbx, 10 ; multiply the multiplier by 10
    add rax, rsi ; add it to our final value
    cmp rdx, rdi ; are we at the end of the string? (1 for negatives, 0 for positives)
    je .atoinc ; if so, jump to the negativity check
    jmp .atoil ; otherwise, continue the loop

.atoinc:
    cmp rdi, TRUE ; is our string number negative?
    je .atoimkn ; if so, make it negative
    jmp .atoie ; otherwise, jump to ending pops

.atoimkn:
    imul rax, -1 ; make the value negative

.atoie:
    pop rsi ; pop off reserved values
    pop rdi
    pop rdx
    pop rbx
    ret ; return to caller

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