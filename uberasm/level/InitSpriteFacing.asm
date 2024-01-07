init:
	JSL InitSpriteFacing_init
	STA $0C
    LDA $010C|!addr
    STA $0D
    JSL MultipersonReset_main

	RTL
