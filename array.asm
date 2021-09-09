; a pseudo-array implementation for x86-64 assembly

; typedef array_type (unsigned byte)
; --------------------------
; int8 (byte) - 0
; int16 (short) - 1
; int32 (int) - 2
; int64 (long) - 3
; uint8 (unsigned byte) - 4
; uint16 (unsigned short) - 5
; uint32 (unsigned int) - 6
; uint64 / pointer (unsigned long) - 7
; bool - 8
; float32 (float) - 9
; float64 (double) - 10

; array<e>
; ------------------
; buffer size should be length + array type + (type size * length)
;
; functions:
; constructor(rcx: buffer, rdx: int, r8: array_type) -> rax: array
; len(rcx: array) -> rax: int
; type(rcx: array) -> rax: unsigned byte
; set(rcx: array, rdx: int, r8: e) -> void
; get(rcx: array, rdx: int) -> rax: e
; print(rcx: array) -> void

%include "stdfunc.asm"

section .data
INT8T: equ 0
INT16T: equ 1
INT32T: equ 2
INT64T: equ 3
UINT8T: equ 4
UINT16T: equ 5
UINT32T: equ 6
UINT64T: equ 7
BOOLT: equ 8
FLOAT32T: equ 9
FLOAT64T: equ 10

plbrack: db "[", 0
prbrack: db "]", 0
pdelim: db ", ", 0

section .text

; constructor(rcx: buffer, rdx: int, r8: array_type) -> rax: array
array:
    mov [ecx], edx
    mov byte [rcx + 4], r8b
    mov rax, rcx
    ret

; len(rcx: array) -> rax: int
array.len:
    xor rax, rax
    mov eax, dword [rcx]
    ret

; type(rcx: array) -> rax: unsigned byte
array.type:
    mov rax, 0
    mov al, byte [rcx + 4]
    ret

; set(rcx: array, rdx: int, r8: E) -> void
array.set:
    call array.type
    cmp rax, INT8T
    je .set_int8
    cmp rax, INT16T
    je .set_int16
    cmp rax, INT32T
    je .set_int32
    cmp rax, INT64T
    je .set_int64
    cmp rax, UINT8T
    je .set_int8
    cmp rax, UINT16T
    je .set_int16
    cmp rax, UINT32T
    je .set_int32
    cmp rax, UINT64T
    je .set_int64
    cmp rax, BOOLT
    je .set_int8
    ret

.set_int8:
    mov byte [rcx + rdx + 5], r8b
    ret

.set_int16:
    mov word [rcx + (rdx * 2) + 5], r8w
    ret

.set_int32:
    mov dword [rcx + (rdx * 4) + 5], r8d
    ret

.set_int64:
    mov qword [rcx + (rdx * 8) + 5], r8
    ret

; get(rcx: array, rdx: int) -> E
array.get:
    call array.type
    mov r8, rax
    xor rax, rax
    cmp r8, INT8T
    je .get_int8
    cmp r8, INT16T
    je .get_int16
    cmp r8, INT32T
    je .get_int32
    cmp r8, INT64T
    je .get_int64
    cmp r8, UINT8T
    je .get_uint8
    cmp r8, UINT16T
    je .get_uint16
    cmp r8, UINT32T
    je .get_uint32
    cmp r8, UINT64T
    je .get_uint64
    cmp r8, BOOLT
    je .get_uint8
    ret

.get_int8:
    mov al, byte [rcx + rdx + 5]
    cbw
    cwde
    cdqe
    ret

.get_int16:
    mov ax, word [rcx + (rdx * 2) + 5]
    cwde
    cdqe
    ret

.get_int32:
    mov eax, dword [rcx + (rdx * 4) + 5]
    cdqe
    ret

.get_int64:
    mov rax, qword [rcx + (rdx * 8) + 5]
    ret

.get_uint8:
    mov al, byte [rcx + rdx + 5]
    ret

.get_uint16:
    mov ax, word [rcx + (rdx * 2) + 5]
    ret

.get_uint32:
    mov eax, dword [rcx + (rdx * 4) + 5]
    ret

.get_uint64:
    mov rax, qword [rcx + (rdx * 8) + 5]
    ret

; print(rcx: array) -> void
array.print:
    push rcx
    push rdx
    push r8
    push rbx
    xor rdx, rdx

    push rcx
    push rdx
    push r8
    mov rcx, plbrack
    call prints
    pop r8
    pop rdx
    pop rcx
    call array.len
    mov r8, rax
    call array.type
    mov rbx, rax

.aprintgs:
    cmp r8, rdx
    je .aprinte

    cmp rbx, UINT64T
    jle .aprinti
    cmp rbx, BOOLT
    je .aprintb

.aprintg:
    cmp r8, rdx
    je .aprinte

    push rcx
    push rdx
    push r8
    mov rcx, pdelim
    call prints
    pop r8
    pop rdx
    pop rcx

    cmp rbx, UINT64T
    jle .aprinti
    cmp rbx, BOOLT
    je .aprintb

.aprinti:
    push rcx
    push rdx
    push r8
    call array.get
    mov rcx, rax
    call printi
    pop r8
    pop rdx
    pop rcx

    inc rdx
    jmp .aprintg

.aprintb:
    push rcx
    push rdx
    push r8
    call array.get
    mov rcx, rax
    call printb
    pop r8
    pop rdx
    pop rcx

    inc rdx
    jmp .aprintg

.aprinte:
    push rcx
    push rdx
    push r8
    mov rcx, prbrack
    call prints
    pop r8
    pop rdx
    pop rcx

    pop rbx
    pop r8
    pop rdx
    pop rcx
    ret