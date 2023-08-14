; Speed (Self-explanatory)
; Valid values are 00, 01, 03, 07, 0F, 1F, 3F, 7F, and FF
; (being 00 the faster and FF the slower)
	!Speed		= $00
	
; Direction (Self-explanatory)
; Valid values are !Left, !Right, !Up, !Down, !DiagUL, !DiagUR, !DiagDL, !DiagDR
	!Direction	= !Left
	
; Disable Scroll on No-Yoshi intro.
; Valid values are 0 (Enable) or 1 (Disable)
	!Intro		= 1

; End of customizable options
; Code below, don't change unless you know what you are doing

!Left = 0	:	!Right = 1	:	!Up = 2		:	!Down = 3
!DiagUL = 4	:	!DiagUR = 5	:	!DiagDL = 6	:	!DiagDR = 7

main:
LDA $9D			; Checks animation lock flag
ORA $13D4|!addr		; or pause flag
BNE .stop		; then stop the scroll

	if !Intro
LDA $71			; Checks the player's animation
CMP #$0A		; then if a No-Yoshi intro is going
BEQ .stop		; stop the scroll until it's over
	endif

LDA $14
AND #!Speed
BNE +
REP #$20
	if !Direction == !Left	||	!Direction == !DiagUL	||	!Direction == !DiagDL
INC $1466|!addr
	endif
	if !Direction == !Right	||	!Direction == !DiagUR	||	!Direction == !DiagDR
DEC $1466|!addr
	endif
	if !Direction == !Up	||	!Direction == !DiagUL	||	!Direction == !DiagUR
INC $1468|!addr
	endif
	if !Direction == !Down	||	!Direction == !DiagDL	||	!Direction == !DiagDR
DEC $1468|!addr
	endif
SEP #$20
+

.stop:
RTL