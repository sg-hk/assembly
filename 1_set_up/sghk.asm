;; first try:
;; I had initially simply written
;; global _start
;; and tried to compile with "nasm sghk.asm"
;; this produced an empty file

.globl _start    

.text           
_start:
    mov x16, #1    
    mov x0, #0      
    svc #0x80      


;; lessons:
;; 1. code
;; global _start is the entry point
;; _start: then needs to be defined
;; to simply exit you still need to load up a register and syscall
;; 2. compilation
;; the correct command is
;; nasm -f elf64 file.asm -o file.o && ld file.o -o file
;; on macOS:
;; clang -c file.ask -o file && ld file.o -o sghk -lSystem -syslibroot `xcrun --show-sdk-path` -e _start
