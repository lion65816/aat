load:
	STZ $187A|!addr		;> Player on Yoshi (within levels) flag. Zero out just in case.
	STZ $0DC1|!addr		;> Reset player on Yoshi (within levels and on the overworld) flag.
	RTL
init:
	JSL start_select_init
	JSL MultipersonReset_init
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
.return
	RTL
