.section __BSS, __bss
_res_str:  .space  64

.section __DATA, __data
_newline:  .byte 10 ; "\n" in ASCII

.section __TEXT, __text
; this prints one byte to stdout
.macro _PRINT _num
  mov   x0, #1
  adrp  x1, \_num@PAGE
  add   x1, x1, \_num@PAGEOFF
  mov   x2, #1
  mov   x16, #4
  svc   #0x80
.endm

.global _start
_start:
  cmp     x0, #2
  b.ne     _exit
  ldrb    w2, [x1]  ; argv[1]
  
  ; this doesn't work because we need to do atoi, then +1, then itoa...
  add     w2, w2, #1
  strb    w2, [x1]
  
  mov     x0, #1 ; fd
  mov     x2, #1 ; len
  mov     x16, #4
  svc     #0x80

  _PRINT  _newline

_exit:
  mov   x0, #0
  mov   x16, #1
  svc   #0x80
