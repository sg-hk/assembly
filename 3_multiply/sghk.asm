	.section __DATA,__data
_one_n:		.long 42
_two_n:		.long 33
_counter:	.long 0
_res:		.long 0
_res_str:	.space 10

	.section __TEXT,__text
	.globl _start
_start:
        ; load up all the vars
	adrp	x8, _one_n@PAGE
	add	x8, x8, _one_n@PAGEOFF
	ldr	w8, [x8]           

	adrp	x9, _two_n@PAGE
	add	x9, x9, _two_n@PAGEOFF
	ldr	w9, [x9]           

	adrp	x10, _counter@PAGE
	add	x10, x10, _counter@PAGEOFF
	ldr	w10, [x10]         

	adrp	x11, _res@PAGE
	add	x11, x11, _res@PAGEOFF
	ldr	w11, [x11]          

	; multiplication loop: res += one_n until counter == two_n
loop:
	add	w11, w11, w8      ; res += one_n 
	add	w10, w10, #1      ; ++counter
	cmp	w10, w9           ; counter == two_n ?
	b.ne	loop

; code = chat-gpt, comments = me
	; convert res to string (in reverse order)
	mov	w0, w11           ; move res to w0 for conversion
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
	; write syscall: write(fd=1, buf=_res_str, len=x20)
	mov	x0, #1           
	adrp	x1, _res_str@PAGE
	add	x1, x1, _res_str@PAGEOFF
	mov	x2, x20          
	mov	x16, #4   
	svc	#0x80

	; exit syscall: exit(status=0)
	mov	x0, #0          
	mov	x16, #1   
	svc	#0x80
