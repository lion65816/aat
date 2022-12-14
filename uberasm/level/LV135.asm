	; Horizontal level wrap
;  This connects the top and bottom of the screen, wrapping sprites and Mario from one to the other.
;
; Coded by kaizoman666 / Thomas.
!InputByte1 = #%00000000
!InputByte2 = #%00110000

!topEdge = $00A0	; where the "top" wrap point is
!botEdge = $01A0	; where the "bottom" wrap point is


;; Code below this point ---------------------------------------

!dist = !botEdge-!topEdge


init:

LDA #$00
STA $14AF|!addr

	LDA $19
	BEQ +
	LDA #$01
	STA $19
+	LDA $0DC2|!addr
	BEQ +
	LDA #$01
	STA $0DC2|!addr
+	RTL


load:
    lda #$01 : sta $1B9B|!addr
    rtl
    
Main:
STZ $140D|!addr

LDA #$00
STA $1697|!addr
.go
	LDA !InputByte1		; Load input
	AND #%10110000		; Bitmask of which bits not to run through $15
	BEQ +				; If none of these bits are set, branch
	EOR !InputByte1		; Flip masked bits out for now
	TRB $15				; Reset bits for currently held down controller buttons
	TRB $16
	EOR !InputByte1		; Flip back the bits previously disabled
	TSB $0DAA|!addr		; And set those ones here, allowing to hold some buttons.
	TSB $0DAB|!addr		; Same for second controller
	BRA ++				; Branch to second input
+	LDA !InputByte1		; Reload data
	TSB $0DAA|!addr		;\ Since none of the masked bits were set,
	TSB $0DAB|!addr		;|
	TRB $15				;/ Just disable them at addresses as normal. (including second controller)
	TRB $16
++	LDA !InputByte2		;\ Disable second byte normally as there are no exeptions.
	TRB $17				;|
	TSB $0DAC|!addr		;/
	TSB $0DAD|!addr		; Same for controller 2
	
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

