init:
	JSL FilterFireCape_init
	JSL gradient_jumpers_init

	; Set On/Off Switch value to On.
	LDA #$00
	STA $14AF|!addr

	RTL

main:
	JSL freezetimer_main
	RTL
