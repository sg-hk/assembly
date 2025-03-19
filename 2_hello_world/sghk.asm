.globl _start    

.data
msg:     .asciz "Hello, world!"
        ; variables have an arbitrary label (msg) and a defined directive (asciz)
        ; asciz is null-terminated, ascii isn't

.text           
_start:
        ; write syscall has args: fd, buf, len
        mov x0, #1              ; x0 is fd, #1 is stdout
        adrp x1, msg@PAGE       ; adrp loads the page-aligned address of a variable
                                ; macOS needs page-relative addressing
                                ; @PAGE is the 4KB-aligned page that contains msg
                                ; returns upper 52 bits of the 64-bit address
        add x1, x1, msg@PAGEOFF ; add (destination), (source), (value)
                                ; msg@PAGEOFF is the missing 12 bits (the offset)
        mov x2, #13             ; 13 is length of msg
                                ; "x" registers are 64bit ints
                                ; "w" 32b int; "d" 64b float; "s" 32b float
                                ; 64 and 32 variants occupy same space. 32 is lower half
        mov x16, #4             ; write is syscall 4
        svc #0x80

        ; exit syscall
        mov x16, #1
        mov x0, #0              ; here x0 is not fd, just exit status
        svc #0x80      
