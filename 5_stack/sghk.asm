.section __BSS, __bss
_array_n:     .space 16
_res_str:     .space 64

.section __DATA, __data
_first_n:     .long 1
_second_n:    .long 2
_third_n:     .long 3
_array_n:     .space 16
_res_str:     .space 64
_new_line:    .byte 10 ; "\n" in ASCII

.section __TEXT, __text
.macro _PUSH _arr, _num
  adrp  x0, _arr@PAGE
  add   x0, x0, _arr@PAGEOFF
  adrp  x1, _num@PAGE
  add   x1, x1, _num@PAGEOFF
  str   x1, [x0]
.endm
.macro _POP _arr, _num
  adrp  x0, _arr@PAGE
  add   x0, x0, _arr@PAGEOFF
  adrp  x1, _num@PAGE
  add   x1, x1, _num@PAGEOFF
.endm
.macro _PRINT_INT _number, _string
  adrp  w0, _number@PAGE
  add   w0, w0, _number@PAGEOFF
  adrp	x12, _res_str@PAGE
  add	x12, x12, _res_str@PAGEOFF 
  mov	w13, #10          ; the base (10)
itoa:
  ; we first get the last digit
  udiv	w14, w0, w13      ; res/10 (no decimals)
  mul	w15, w14, w13     ; (res/10)*10, eg 333 becomes 330
  sub	w16, w0, w15      ; res - (res/10)*10, eg 333-330 = last digit
  ; then we convert to ASCII
  add	w16, w16, #48     ; add 48 = ASCII value for digit 
  strb	w16, [x12], #1    ; store 1 byte (ASCII variable) in string
  ; and increment string: point to next char
  mov	w0, w14           ; copy the quotient (res/10 no dec.) in res
  cbnz	w0, itoa          ; if quotient != 0, continue
  ; cbnz is an optimization of cmp, bne

  ; then we do strlen
  adrp	x17, _res_str@PAGE
  add	x17, x17, _res_str@PAGEOFF ; x17 points to start of str
  mov	x20, x12          ; x12 points to end of str (after last char)
  sub	x20, x20, x17     ; end-start = len

  ; now reverse
  sub	x12, x12, #1      ; we decrement to point at last char
rev:
  cmp	x17, x12
  b.ge	print             ; go to print when at string start
  ldrb	w19, [x17]        ; load byte at start
  ldrb	w21, [x12]        ; load byte at end
  strb	w21, [x17]        ; swap bytes
  strb	w19, [x12]
  add	x17, x17, #1      ; increment start, decrement end
  sub	x12, x12, #1
  b	rev               ; unconditional branch: loop no matter what

  ; and finally print
print:
  mov	x0, #1           
  adrp	x1, _res_str@PAGE
  add	x1, x1, _res_str@PAGEOFF
  mov	x2, x20          
  mov	x16, #4   
  svc	#0x80
  ; also print new line
  mov	x0, #1           
  adrp  x1, _new_line@PAGE
  add   x1, x1, _new_line@PAGEOFF
  mov	x2, #1
  mov	x16, #4   
  svc	#0x80
.endm

.global _start
_start:
  
