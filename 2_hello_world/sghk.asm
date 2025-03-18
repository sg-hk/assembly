.globl _start    

.data
msg:     .asciz "Hello, world!"
;; variables have an arbitrary label (msg) and a defined directive (asciz)
;; asciz is null-terminated, ascii isn't

.text           
_start:
        ;; write syscall has args: fd, buf, len
        mov x0, #1   ;; x0 is fd, #1 is stdout
        ;; the below instruction does not work on Apple
        ldr x1, =msg ;; ldr loads from memory. x1 is a 64-bit register 
                     ;; also, we need the address of msg (=msg) not msg
                     ;; i.e. x1 holds a pointer to the buffer
        mov x2, #13  ;; 13 is length of msg. x2 is a 64-bit register
        mov x16, #4  ;; x16 is syscall, #4 is write 
        svc #0x80

        ;; exit syscall
        mov x16, #1
        mov x0, #0   ;; here x0 is not fd, just exit status
        svc #0x80      
