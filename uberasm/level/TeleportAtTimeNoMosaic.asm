; teleport_on_no_time.asm
;
; this code will teleport the player to the specified level
;	when the timer hits a certain value (default is 001)
;	(000 will work, but it'll also kill the player)
;

!time_high  = $00	; the hundreds place of the time value to teleport at
!time_mid	= $00	; the tens place of the time value to teleport at
!time_low	= $01	; the ones place of the time value to teleport at

; Speed (Self-explanatory)
; Valid values are 00, 01, 03, 07, 0F, 1F, 3F, 7F, and FF
; (being 00 the faster and FF the slower)
	!Speed		= $03
	
; Direction (Self-explanatory)
; Valid values are !Left, !Right, !Up, !Down, !DiagUL, !DiagUR, !DiagDL, !DiagDR
	!Direction	= !Down
	
; Disable Scroll on No-Yoshi intro.
; Valid values are 0 (Enable) or 1 (Disable)
	!Intro		= 1

; End of customizable options
; Code below, don't change unless you know what you are doing

!Left = 0	:	!Right = 1	:	!Up = 2		:	!Down = 3
!DiagUL = 4	:	!DiagUR = 5	:	!DiagDL = 6	:	!DiagDR = 7

load:
	JSL NoStatus_load
RTL

main:
	LDA #%11101111 : STA $00
	LDA #%11110000 : STA $01
	JSL DisableButton_main
	LDA #$FF
	STA $13D3|!addr
LDA $9D			; Checks animation lock flag
ORA $13D4|!addr		; or pause flag
BNE .stop		; then stop the scroll

	if !Intro
LDA $71			; Checks the player's animation
CMP #$0A		; then if a No-Yoshi intro is going
BEQ .stop		; stop the scroll until it's over
	endif

LDA $5B
BPL +

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

	; check timer value
	
	LDA $0F31|!addr
	CMP #!time_high
	BNE .stop
	LDA $0F32|!addr
	CMP #!time_mid
	BNE .stop
	LDA $0F33|!addr
	CMP #!time_low
	BNE .stop
	LDA #$2A
	STA $0100|!addr
.stop:
RTL
