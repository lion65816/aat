main:
	JSL BG_AutoScroll4_main

	; This code will reload the current room.
	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL MultipersonReset_main
	RTL
