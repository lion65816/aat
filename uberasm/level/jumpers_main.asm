load:
	JSL FilterYoshi_load
	RTL

init:
	JSL FilterFireCape_init
	JSL freescrollbabey_init
	JSL gradient_jumpers_init

	; Set On/Off Switch value to On.
	LDA #$00
	STA $14AF|!addr

	RTL

main:
	; Don't keep track of consecutive enemies stomped counter.
	LDA #$00
	STA $1697|!addr

	; Disable L and R buttons.
	LDA #%00000000 : STA $00
	LDA #%00110000 : STA $01
	JSL DisableButton_main
	RTL
