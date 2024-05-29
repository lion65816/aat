init:
	JSL clusterspawn_uberASM_init
	JSL gradient_purkinje_init
	RTL

main:
	REP #$21	;replica of relevant code from $00F6DB
	LDA $142A|!addr
	ADC.w #$000C
	STA $06
	SEC
	SBC.w #$0018
	STA $04
	LDA $1462|!addr
	STA $08
	LDY.b #$02
	LDA $94
	SEC
	SBC $08
	STA $00
	CMP $142A|!addr
	BPL +
	LDY #$00
+
	SEC
	SBC.w $0004|!dp,y
	BNE +
	SEP #$20
	RTL
+
	STA $02
	EOR.w xormask,y
	BPL .ret
	LDY $13FD|!addr
	BNE +
	LDX $13FF|!addr
	LDY #$08
	LDA $142A|!addr
	CMP.w dataF6B3,x
	BPL ++
	LDY #$0A
++
	LDA.w dataF6C1-2,y
	EOR $02
	BPL +
	LDA.w dataF6C1-2,x
	EOR $02
	BPL +
	LDA $02
	CLC
	ADC.w dataF6D7-8,y
	BEQ +
	STA $02
+
	LDA $02
	CLC
	ADC $08
	BPL +
	LDA.w #$0000
+
	STA $08
	LDA $5E
	DEC
	XBA
	AND.w #$FF00
	BPL +
	LDA.w #$0080
+
	CMP $08
	BPL +
	STA $08
+
	;now compare the result with the previous frame scroll
	LDA $08
-
	AND #$FFF0
	STA $0A
	LDY #$02
	LDA $1462|!addr
	AND #$FFF0
	SEC
	SBC $0A
	BEQ .ret
	BPL +
	LDY #$00
	EOR #$FFFF
	INC
+
	CMP #$0020	;check if a column would be skipped this frame
	BCC .ret
	LDA $142A|!addr
	SBC.w offset142A,y
	STA $142A|!addr
	LDA $08
	CLC
	ADC.w offset142A,y
	STA $08
	BRA -
.ret
	SEP #$20
	RTL
	
xormask:
dw $0000,$FFFF
dataF6B3:
dw $0090,$0060,$0000
dw $0000,$0000,$0000
dw $0000
dataF6C1:
dw $FFFE,$0002,$0000
dw $FFFE,$0002,$0000
dataF6D7:
dw $0001,$FFFF
offset142A:
dw $FFF0,$0010