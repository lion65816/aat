load:
	JSL FilterYoshi_load
	RTL
	
init:
	JSL MultipersonReset_init
	RTL
	
main:
	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL MultipersonReset_main
	RTL
