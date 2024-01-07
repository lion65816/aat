load:
	JSL FilterYoshi_load
	RTL
	
main:
    LDA $010B|!addr
    STA $0C
    LDA $010C|!addr
    STA $0D
    JSL MultipersonReset_main
    RTL

