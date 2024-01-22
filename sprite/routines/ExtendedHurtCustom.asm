;; extended sprite <-> player interaction that allows custom extended sprite hitbox.
;Input:
;$00 - X-offset
;$01 - width
;$02 - Y-offset
;$03 - height

	LDA $171F|!Base2,x
	CLC
	ADC $00
	STA $04

	LDA $1733|!Base2,x
	ADC #$00
	STA $0A

	LDA $01
	STA $06

	LDA $1715|!Base2,x
	CLC
	ADC $02
	STA $05

	LDA $1729|!Base2,x
	ADC #$00
	STA $0B

	LDA $03
	STA $07

JSL $03B664|!BankB		;get mario's clipping
JSL $03B72B|!BankB		;check contact
BCC .DiffRe			;

PHB				;
LDA.b #$02			;	
PHA				;
PLB				;
PHK				;
PEA.w .return-1			;
PEA.w $B889-1

JML $02A469|!BankB		;hurt mario

.return
	PLB 
.DiffRe
	RTL
