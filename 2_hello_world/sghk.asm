.globl _start    

.data
msg:     .asciz "Hello, world!"
        ;; variables have an arbitrary label (msg) and a defined directive (asciz)
        ;; asciz is null-terminated, ascii isn't

.text           
_start:
        ;; write syscall has args: fd, buf, len
        mov x0, #1              ;; x0 is fd, #1 is stdout
        adrp x1, msg@PAGE       ;; adrp loads the page-aligned address of a variable
                                ;; macOS needs page-relative addressing
                                ;; @PAGE is the 4KB-aligned page that contains msg
                                ;; returns upper 52 bits of the 64-bit address
        add x1, x1, msg@PAGEOFF ;; add (destination), (source), (value)
                                ;; msg@PAGEOFF is the missing 12 bits (the offset)
        mov x2, #13             ;; 13 is length of msg. x2 is a 64-bit register
        mov x16, #4             ;; x16 is syscall, #4 is write 
        svc #0x80

        ;; exit syscall
        mov x16, #1
        mov x0, #0              ;; here x0 is not fd, just exit status
        svc #0x80      
