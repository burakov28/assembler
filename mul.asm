                section .text

                global _start

_start:
                lea r8, [rsp - 6 * 8 * 128]

                mov r15, 128
                mov r14, r8; first empty cell

                mov rdi, r14
                lea rcx, [r15 + 4 * r15]
                call set_zero

                lea r9, [r8 + 4 * 8 * 128]
                call read_long

                lea r9, [r9 - 8 * 128]
                call read_long

                lea r8, [r9 + 8 * 128]
                call mul_long_long
                mov r9, r14
                lea r15, [r15 + r15]
                call write_long
                call exit

;r9 first operand
;r8 second operand
mul_long_long:
                push r9
                push r8
                push r14
                mov r12, r15
                lea r10, [r9 - 8 * 128]

.loop:
                mov rbx, [r9]
                call mul_long_short
                call add_long_long
                add r14, 8
                add r9, 8
                sub r12, 1
                jnz .loop

                pop r14
                pop r8
                pop r9
                ret

;r14 - first arg
;r10 - second arg
;r14 - ans
add_long_long:
                push r15
                push r14
                push r10
                xor rcx, rcx

.loop:
                xor rdx, rdx
                mov rax, [r10]
                add rax, rcx;
                adc rdx, 0
                add [r14], rax
                adc rdx, 0
                mov rcx, rdx
                add r14, 8
                add r10, 8
                sub r15, 1
                jnz .loop

                pop r10
                pop r14
                pop r15
                ret



read_char:
                xor rax, rax
                xor rdi, rdi
                sub r14, 1
                mov rsi, r14
                mov rdx, 1
                syscall
                cmp rax, 1
                jne .error
                mov al, [r14]
                add r14, 1
                ret

.error:
                mov rax, -1
                add r14, 1
                ret


;r9 - begin
;r15 - length
read_long:

.loop:

                call read_char
                or rax, rax
                js .invalid_char
                cmp rax, 0x0a
                je .done
                cmp rax, '0'
                jb .invalid_char
                cmp rax, '9'
                ja .invalid_char


                mov rbx, 10

                push r8
                push r10
                mov r8, r9
                mov r10, r9
                call mul_long_short
                pop r10
                pop r8
                ;mov r10, [r9]
                ;call print_number
                sub rax, '0'
                call add_long_short
                ;mov r10, [r9]
                ;call print_number
                jmp .loop

.done:
                ret

.invalid_char:
                mov rax, 1
                mov rdi, 1
                mov rsi, invalid_char_msg
                mov rdx, invalid_char_msg_size
                syscall
                mov al, 0x0a
                call write_char
                call exit

;r8 - begin
;r15 - length
;r10 - answer
;rbx - multer
mul_long_short:
                push r15
                push r10
                push rax
                xor rdi, rdi
                mov rsi, r8
.loop:
                mov rax, [rsi]
                mul rbx
                add rax, rdi
                adc rdx, 0
                mov [r10], rax
                mov rdi, rdx
                add rsi, 8
                add r10, 8
                sub r15, 1
                jnz .loop

                pop rax
                pop r10
                pop r15
                ret

;r9 - begin
;r15 - length
;rax - summand
add_long_short:
                push r15
                push r10
                xor r10, r10
                mov rsi, r9
.loop:
                xor rdx, rdx
                add [rsi], rax;
                adc rdx, 0
                add [rsi], r10

                adc rdx, 0
                xor rax, rax
                mov r10, rdx
                add rsi, 8
                sub r15, 1
                jnz .loop

                pop r10
                pop r15
                ret


;r15 - length
;r9 - begin
;rbx - devider
;rdx -remainder
div_long_short:
                push r15
                lea rsi, [r9 + r15 * 8 - 8]
                xor rdx, rdx
.loop:
                mov rax, [rsi]
                ;push r10
                ;mov r10, rax
                ;call print_number
                ;pop r10
                div rbx
                mov [rsi], rax
                sub rsi, 8;
                sub r15, 1
                jnz .loop
                pop r15
                ret


;r9 - begin
write_long:
                push r14
                push r10
                xor r10, r10
.loop:
                mov rbx, 10
                call div_long_short
                sub r14, 1
                add r10, 1
                ;call print_number
                add rdx, '0'
                mov [r14], dl
                mov rdi, r9
                mov rcx, r15

                call is_zero
                jnz .loop
                ;call print_number
                call print_string
                pop r10
                pop r14
                ret

;r14 - begin
;r10 - length
print_string:
                ;call print_number
                mov rax, 1
                mov rdi, 0

                mov rsi, r14
                mov rdx, r10
                syscall
                mov al, 0x0a
                call write_char
                ret

;al - sign
write_char:
                sub r14, 1
                mov [r14], al
                mov rax, 1
                mov rdi, 1
                mov rsi, r14
                mov rdx, 1
                syscall
                add r14, 1
                ret


;r10 - output
print_number:
                push rax
                push rsi
                push rdx
                push rdi
                push rcx
                push rbx
                mov rax, r10

.loop:
                mov rbx, 10
                xor rdx, rdx
                div rbx
                push rax
                mov al, dl
                add al, '0'
                call write_char
                pop rax
                cmp rax, 0
                jne .loop

                mov al, 0x0a
                call write_char
                pop rbx
                pop rcx
                pop rdi
                pop rdx
                pop rsi
                pop rax
                ret

set_zero:
                push            rax
                push            rdi
                push            rcx

                xor             rax, rax
                rep stosq


                pop             rcx
                pop             rdi
                pop             rax
                ;call print_number
                ret

is_zero:
                push            rax
                push            rdi
                push            rcx

                xor             rax, rax
                rep scasq

                pop             rcx
                pop             rdi
                pop             rax
                ret


exit:
                mov rax, 60
                xor rdi, rdi
                syscall




                section         .rodata
invalid_char_msg:
                db              "Invalid character"
invalid_char_msg_size: equ             $ - invalid_char_msg

