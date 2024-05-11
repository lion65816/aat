; Speed (Self-explanatory)
; Valid values are 00, 01, 03, 07, 0F, 1F, 3F, 7F, and FF
; (being 00 the faster and FF the slower)
	!Speed		= $00
	!Speed2		= $07
	
; Direction (Self-explanatory)
; Valid values are !Left, !Right, !Up, !Down, !DiagUL, !DiagUR, !DiagDL, !DiagDR
	!Direction	= !DiagUL
	
; Disable Scroll on No-Yoshi intro.
; Valid values are 0 (Enable) or 1 (Disable)
	!Intro		= 1

; End of customizable options
; Code below, don't change unless you know what you are doing

!Left = 0	:	!Right = 1	:	!Up = 2		:	!Down = 3
!DiagUL = 4	:	!DiagUR = 5	:	!DiagDL = 6	:	!DiagDR = 7

init:
	JSL start_select_init
	RTL

main:
	JSL start_select_main

	; Reload the room upon death.
	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL MultipersonReset_main

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
INC $1462|!addr
INC $1462|!addr
	endif
	if !Direction == !Right	||	!Direction == !DiagUR	||	!Direction == !DiagDR
DEC $1462|!addr
DEC $1462|!addr
	endif
SEP #$20
	+
LDA $14
AND #!Speed2
BNE ++
REP #$20
	if !Direction == !Up	||	!Direction == !DiagUL	||	!Direction == !DiagUR
INC $1464|!addr
	endif
	if !Direction == !Down	||	!Direction == !DiagDL	||	!Direction == !DiagDR
DEC $1464|!addr
	endif
SEP #$20
++

.stop:
RTL