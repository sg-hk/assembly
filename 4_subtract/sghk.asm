; implement subtraction in assembly
; output should be negative, and print to stdout

.section __DATA, __data
_one_n:       .long 10
_two_n:       .long 20
_res:         .long 0
_res_str:     .space 64
_minus:       .byte 45 ; "-" in ASCII
_new_line:    .byte 10 ; "\n" in ASCII

.section __TEXT, __text
.global _start
_start:
  ; load vars
  adrp x0, _one_n@PAGE
  add  x0, x0, _one_n@PAGEOFF
  ldr  w0, [x0]

  adrp x1, _two_n@PAGE
  add  x1, x1, _two_n@PAGEOFF
  ldr  w1, [x1]

  adrp x2, _res@PAGE
  add  x2, x2, _res@PAGEOFF
  ldr  w2, [x2]


  ; sub (destination), (source), (value)
  sub  w2, w0, w1
  ; ensure that source > value
  cmp  w0, w1
  bge  conv
  ; 2 complement
  mov  w3, w0 ; save source
  mov  w4, w1 ; and value for later cmp
  mvn  w2, w2 ; invert bits
  add  w2, w2, #1 ; add one
  
conv:
  ; num to ASCII
  mov	w0, w2            ; move res to w0 for conversion
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

print:
  cmp w3, w4
  bge pos_print
  ; print "-" first if negative
  mov	x0, #1           
  adrp  x1, _minus@PAGE
  add   x1, x1, _minus@PAGEOFF
  mov	x2, #1
  mov	x16, #4   
  svc	#0x80
pos_print:
  ; then the number 
  mov	x0, #1           
  adrp	x1, _res_str@PAGE
  add	x1, x1, _res_str@PAGEOFF
  mov	x2, x20          
  mov	x16, #4   
  svc	#0x80
  ; then a new line
  mov	x0, #1           
  adrp  x1, _new_line@PAGE
  add   x1, x1, _new_line@PAGEOFF
  mov	x2, #1
  mov	x16, #4   
  svc	#0x80

  ; exit syscall: exit(status=0)
  mov	x0, #0          
  mov	x16, #1   
  svc	#0x80
