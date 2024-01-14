init:
	LDA $19
	CMP #$03
	BNE +
	STZ $19
	INC $19
	+
RTL

main:
	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL MultipersonReset_main

	LDA $19
	CMP #$03
	BNE +
	JSL $00F606|!bank
	+
RTL
