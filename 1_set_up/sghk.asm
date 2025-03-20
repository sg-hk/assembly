.globl _start   ; define the entry point 

.text           ; code section
_start:
    mov x16, #1 ; x16 is the syscall register
                ; exit is syscall 1
    mov x0, #0  ; assign 0 to the exit status
    svc #0x80   ; execute syscall ("SuperVisor Command")

; compilation commands
; x86 linux
; nasm -f elf64 file.asm -o file.o && ld file.o -o file
; macOS
; clang -c file.asm -o file.o && ld file.o -o file -lSystem -syslibroot `xcrun --show-sdk-path` -e _start
