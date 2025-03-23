.section __BSS, __bss
_array_n:     .space 16
_res_str:     .space 64

.section __DATA, __data
_first_n:     .long 1
_second_n:    .long 2
_third_n:     .long 3
_newline:     .byte 10 ; "\n" in ASCII

.section __TEXT, __text
.macro _PRINT_INT _number, _string
  adrp    x2, \_number@PAGE
  add     x2, x2, \_number@PAGEOFF
  ldr     w0, [x2]

  adrp    x12, \_string@PAGE
  add     x12, x12, \_string@PAGEOFF

  mov     w13, #10          // base 10

1:  // itoa loop
  udiv    w14, w0, w13      
  mul     w15, w14, w13     
  sub     w16, w0, w15      
  add     w16, w16, #48     
  strb    w16, [x12], #1    
  mov     w0, w14           
  cbnz    w0, 1b            // branch back to label 1

  adrp    x17, \_string@PAGE
  add     x17, x17, \_string@PAGEOFF  
  mov     x20, x12          
  sub     x20, x20, x17     

  sub     x12, x12, #1      

2:  // reverse loop
  cmp     x17, x12
  b.ge    3f                // forward to label 3
  ldrb    w19, [x17]        
  ldrb    w21, [x12]        
  strb    w21, [x17]        
  strb    w19, [x12]
  add     x17, x17, #1      
  sub     x12, x12, #1
  b       2b                // branch back to label 2

3:  // print
  mov     x0, #1           
  adrp    x1, \_string@PAGE
  add     x1, x1, \_string@PAGEOFF
  mov     x2, x20          
  mov     x16, #4   
  svc     #0x80
.endm

.global _start
_start:
  _PRINT_INT _first_n, _res_str
  // add newline
  mov   x0, #1
  adrp  x1, _newline@PAGE
  add   x1, x1, _newline@PAGEOFF
  mov   x2, #1
  mov   x16, #4
  svc   #0x80

  ; exit syscall: exit(status=0)
  mov	x0, #0          
  mov	x16, #1   
  svc	#0x80
