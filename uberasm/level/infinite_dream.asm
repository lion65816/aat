load:
	JSL FilterYoshi_load
	RTL

init:
	;JSL FilterFireCape_init

	; Set On/Off Switch value to On.
	LDA #$00
	STA $14AF|!addr

	RTL

; Horizontal level wrap
;  This connects the top and bottom of the screen, wrapping sprites and Mario from one to the other.
;
; Coded by kaizoman666 / Thomas.

!topEdge = $00A0	; where the "top" wrap point is
!botEdge = $01A0	; where the "bottom" wrap point is

;; Code below this point ---------------------------------------

!dist = !botEdge-!topEdge

main:
	; Disable spin jump.
	STZ $140D|!addr

	; Don't keep track of consecutive enemies stomped counter.
	LDA #$00
	STA $1697|!addr

	; Disable L and R buttons.
	LDA #%00000000 : STA $00
	LDA #%00110000 : STA $01
	JSL DisableButton_main
	
	LDA $9D
	BNE .noWrap
	JSR WrapMario
	JSR WrapSprites
  .noWrap
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
