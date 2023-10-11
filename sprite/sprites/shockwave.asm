
print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Main
	PLB
print "INIT ",pc
	RTL

XSpd:
db $20,$E0

label_14CF3B:
	RTS
Main:
	JSR label_14CF70
	LDA !14C8,X
	CMP #$08
	BNE label_14CF3B
	LDA $9D
	BNE label_14CF3B
	%SubOffScreen()
	LDA !1588,X
	AND #$03
	BNE label_14CF66
	JSL $01A7DC|!bank
	LDY !157C,X
	LDA.w XSpd,Y
	STA !B6,X
	JSL $01802A|!bank
	RTS
label_14CF66:
	STZ !14C8,X
	RTS

GFXTile:
db $07,$27,$29,$2B
GFXYPos:
db $F0,$00

label_14CF70:
	%GetDrawInfo()
	LDA !157C,X
	STA $02
	LDA $14
	LSR A
	LSR A
	LSR A
	AND #$01
	ASL A
	STA $03
	PHX
	LDX #$01
label_14CF86:
	LDA $00
	STA $0300|!addr,Y
	LDA.w GFXYPos,X
	CLC
	ADC $01
	STA $0301|!addr,Y
	PHX
	TXA
	CLC
	ADC $03
	TAX
	LDA.w GFXTile,X
	STA $0302|!addr,Y
	PLX
	PHX
	LDX $15E9|!addr
	LDA !15F6,X
	LDX $02
	BNE label_14CFAE
	ORA #$40

label_14CFAE:
	ORA $64
	STA $0303|!addr,Y
	PLX
	INY
	INY
	INY
	INY
	DEX
	BPL label_14CF86
	PLX
	LDY #$02
	LDA #$01
	JSL $01B7B3|!bank
	RTS