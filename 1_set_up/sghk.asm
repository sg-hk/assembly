.globl _start    

.text           
_start:
    mov x16, #1 ;; exit syscall (1)
    mov x0, #0 ;; exit status = exit(0)
    svc #0x80      

;; compilation commands
;; x86 linux
;; nasm -f elf64 file.asm -o file.o && ld file.o -o file
;; macOS
;; clang -c file.ask -o file.o && ld file.o -o file -lSystem -syslibroot `xcrun --show-sdk-path` -e _start
