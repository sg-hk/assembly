.section __BSS, __bss
_array_n:     .space 16 ; 4 x 4 bytes integers
_res_str:     .space 64
_popped:      .space 4

.section __DATA, __data
_first_n:     .long 1
_second_n:    .long 2
_third_n:     .long 3
_newline:     .byte 10 ; "\n" in ASCII

.section __TEXT, __text

; this macro converts an int to ASCII and prints it to stdout
.macro _PRINT_INT _number, _string
  adrp    x2, \_number@PAGE
  add     x2, x2, \_number@PAGEOFF
  ldr     w0, [x2]

  adrp    x12, \_string@PAGE
  add     x12, x12, \_string@PAGEOFF

  mov     w13, #10          ; base 10

1:  ; itoa loop
  udiv    w14, w0, w13      
  mul     w15, w14, w13     
  sub     w16, w0, w15      
  add     w16, w16, #48     
  strb    w16, [x12], #1    
  mov     w0, w14           
  cbnz    w0, 1b            ; branch back to label 1

  adrp    x17, \_string@PAGE
  add     x17, x17, \_string@PAGEOFF  
  mov     x20, x12          
  sub     x20, x20, x17     

  sub     x12, x12, #1      

2:  ; reverse loop
  cmp     x17, x12
  b.ge    3f                ; forward to label 3
  ldrb    w19, [x17]        
  ldrb    w21, [x12]        
  strb    w21, [x17]        
  strb    w19, [x12]
  add     x17, x17, #1      
  sub     x12, x12, #1
  b       2b                ; branch back to label 2

3:  ; print
  mov     x0, #1           
  adrp    x1, \_string@PAGE
  add     x1, x1, \_string@PAGEOFF
  mov     x2, x20          
  mov     x16, #4   
  svc     #0x80
.endm

; this macro just prints one byte to stdout
.macro _PRINT _num
  mov   x0, #1
  adrp  x1, \_num@PAGE
  add   x1, x1, \_num@PAGEOFF
  mov   x2, #1
  mov   x16, #4
  svc   #0x80
.endm

.macro _PUSH reg
  uxtw  x9, w9           ; widen index to 64-bit (uxtw: 0 extend)
  lsl   x1, x9, #2       ; offset = index * 4
  add   x2, x0, x1       ; addr = base + offset
  str   \reg, [x2]       ; store value at address
  add   w9, w9, #1       ; increment stack pointer
.endm

.macro _POP reg
  sub   w9, w9, #1       ; decrement stack pointer
  uxtw  x9, w9           ; widen index (uxtw: 0 extend)
  lsl   x1, x9, #2       ; offset = index * 4
  add   x2, x0, x1       ; get address
  ldr   \reg, [x2]       ; load value into reg
.endm

.global _start
.align 2
_start:
  ; set up stack base address
  adrp    x0, _array_n@PAGE
  add     x0, x0, _array_n@PAGEOFF

  ; stack index
  mov     w9, #0

  ; load constants 
  adrp    x11, _first_n@PAGE
  add     x11, x11, _first_n@PAGEOFF
  ldr     w11, [x11]

  adrp    x12, _second_n@PAGE
  add     x12, x12, _second_n@PAGEOFF
  ldr     w12, [x12]

  adrp    x13, _third_n@PAGE
  add     x13, x13, _third_n@PAGEOFF
  ldr     w13, [x13]

  ; === Stack operations ===
  ; Push first and second
  _PUSH   w11
  _PUSH   w12

  ; Pop →  expect second
  _POP    w14
  adrp    x15, _popped@PAGE
  add     x15, x15, _popped@PAGEOFF
  str     w14, [x15]
  _PRINT_INT _popped, _res_str
  _PRINT  _newline

  ; Push third
  _PUSH   w13

  ; Pop →  expect third
  _POP    w14
  str     w14, [x15]
  _PRINT  _newline

  ; Pop →  expect first
  _POP    w14
  str     w14, [x15]
  _PRINT _newline

  ; Exit
  mov   x0, #0
  mov   x16, #1
  svc   #0x80
