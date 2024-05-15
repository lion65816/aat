load:
	JSL MultipersonReset_load
	RTL
	
init:
	JSL start_select_init

	LDA $19
	CMP #$03
	BNE +
	STZ $19
	INC $19
+
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

	LDA $19
	CMP #$03
	BNE .return
	JSL $00F606|!bank
.return
	RTL
