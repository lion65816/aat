init:
	JSL ashspawn_uberASM_Init
	JSL DisableSideExit_init
	RTL

main:
	JSL ashspawn_uberASM_Main

	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL MultipersonReset_main

	RTL
