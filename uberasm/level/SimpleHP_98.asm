init:
	JSL SimpleHP_init
	RTL

main:
	JSL SimpleHP_main
	 LDA $010B|!addr
    STA $0C
    LDA $010C|!addr
    STA $0D
    JSL MultipersonReset_main
    RTL

