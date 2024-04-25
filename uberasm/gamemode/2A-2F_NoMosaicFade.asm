init:
main:
	LDA $0100|!addr
	SEC
	SBC #$1B
	STA $0100|!addr
	ASL
	TAX
	LDA.w CodePtrs-($0F*2),x
	STA $00
	LDA.w CodePtrs-($0F*2)+1,x
	STA $01
	LDA.b #!bank8
	STA $02
	PLA
	PLA
	PLA
	PLB
	PLA
	PLA
	PLA
	PHK
	PEA.w (+)-1
	PEA.w $804C
	JML [!dp]
+
	LDA $0100|!addr
	CMP #$0F
	BCC +
	CMP #$2A
	BCS +
	ADC #$1B
	STA $0100|!addr
+
	JML $009312|!bank
CodePtrs:
dw $9F6F
dw $968E
dw $96D5
dw $A59C
dw $9F6F
dw $A1DA