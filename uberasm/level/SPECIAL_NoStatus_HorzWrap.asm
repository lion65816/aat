; Horizontal level wrap
;  This connects the top and bottom of the screen, wrapping sprites and Mario from one to the other.
;
; Coded by kaizoman666 / Thomas.

!topEdge = $00A0	; where the "top" wrap point is
!botEdge = $01A0	; where the "bottom" wrap point is


;; Code below this point ---------------------------------------
!dist = !botEdge-!topEdge

; Needs to be the same free RAM address as in RequestRetry.asm.
!RetryRequested = $18D8|!addr

load:
	JSL NoStatus_load
	RTL

init:
	JSL RequestRetry_init
	RTL

main:
	LDA $9D
	BNE .noWrap
	JSR WrapMario
	JSR WrapSprites
  .noWrap
 
	; Exit out of SPECIAL rooms with a special button combination (A+X+L+R).
	LDA #%11110000 : STA $00
	JSL RequestRetry_main
	LDA !RetryRequested
	BNE .return

	; Otherwise, the SPECIAL rooms will reload upon death.
	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL MultipersonReset_main
  .return
	RTL

WrapMario:
	LDA $13E0|!addr		; don't wrap if dead
	CMP #$3E
	BEQ .noWrap
	REP #$20
	LDA $96
	CMP #!botEdge
	BMI .checkAbove
	SEC : SBC #!dist
	STA $96
	BRA .noWrap
  .checkAbove
	CMP #!topEdge
	BPL .noWrap
	CLC : ADC #!dist
	STA $96
  .noWrap
	SEP #$20
	RTS


WrapSprites:
	LDX #!sprite_slots-1
  .loop
	LDA !14C8,x
	BEQ .skip
	CMP #$02
	BEQ .skip
	LDA !14D4,x
	XBA
	LDA !D8,x
	REP #$20
	CMP #!botEdge
	BMI .checkAbove
	SEC : SBC #!dist
	SEP #$20
	STA !D8,x
	XBA
	STA !14D4,x
	BRA .skip
  .checkAbove
	CMP #!topEdge
	BPL .skip
	CLC : ADC #!dist
	SEP #$20
	STA !D8,x
	XBA
	STA !14D4,x
  .skip
	SEP #$20
	DEX
	BPL .loop
	RTS