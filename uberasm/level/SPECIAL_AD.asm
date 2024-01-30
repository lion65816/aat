init:
	JSL freescrollbabey_init
	JSL ConstantAutoscrollAD_init
	RTL

main:
	JSL ConstantAutoscrollAD_main

	; This code will reload the current room.
	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL MultipersonReset_main
	RTL
