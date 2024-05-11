init:
	JSL start_select_init
	RTL

main:
	LDA #$03 : STA $1497|!addr	;> Make the player invincible.

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
