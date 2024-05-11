init:
	JSL start_select_init
	JSL ashspawn_uberASM_Init
	RTL

main:
	JSL ashspawn_uberASM_Main
	JSL start_select_main

	; Reload the room upon death.
	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL MultipersonReset_main
.return
	RTL
