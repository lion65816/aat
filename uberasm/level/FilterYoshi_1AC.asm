load:
	JSL FilterYoshi_load
	JSL MultipersonReset_load
	RTL
	
main:
	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL MultipersonReset_main
	RTL
