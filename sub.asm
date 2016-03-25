                section .text

                global _start

_start:
                lea r8, [rsp - 3 * 8 * 128]
                mov r9, r8
                mov r15, 128
                mov r14, r8; first empty cell
                mov rdi, r9
                mov rcx, r15
                call set_zero
                call read_long


                lea r9, [r8 + 8 * 128]

                mov rdi, r9
                mov rcx, r15
                ;mov [r9], r15
                ;mov r10, [r9 + 8]
                ;call print_number
                call set_zero
                call read_long
                call compare
                cmp rax, 1
                jne .not_swap
                mov al, '-'
                call write_char
                ;call write_long
                mov rax, r9
                mov r9, r8
                mov r8, rax

.not_swap:

                ;call write_long
                call sub_long_long
                call write_long
                call exit

;r8 - bigger number
;r9 - smaller number
;r15 - length
sub_long_long:
                mov rsi, r8
                mov rdi, r9
                push r10
                push r15
                xor r10, r10
.loop:
                xor rdx, rdx
                mov rax, [rsi]
                sub rax, r10
                adc rdx, 0
                xor r10, r10
                sub rax, [rdi]
                adc rdx, 0
                mov [rdi], rax
                mov r10, rdx
                add rsi, 8
                add rdi, 8
                sub r15, 1
                jnz .loop

                pop r15
                pop r10
                ret


;r8 - begin fisrt number
;r9 - begin of number
;rax = 1 if r8 < r9
compare:
                push r15
                lea rsi, [r8 + r15 * 8 - 8]
                lea rdi, [r9 + r15 * 8 - 8]

.loop:
                mov rax, [rsi]
                cmp rax, [rdi]
                ja .bigger
                jb .smaller
                sub rsi, 8
                sub rdi, 8
                sub r15, 1
                jnz .loop
                jmp .bigger

.bigger:
                xor rax, rax
                pop r15
                ret

.smaller:
                mov rax, 1
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
                call mul_long_short
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

;r9 - begin
;r15 - length
;rbx - multer
mul_long_short:
                push r15
                push r10
                push rax
                xor r10, r10
                mov rsi, r9
.loop:
                mov rax, [rsi]
                mul rbx
                add rax, r10
                adc rdx, 0
                mov [rsi], rax
                mov r10, rdx
                add rsi, 8
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
                mov rdi, 1

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

