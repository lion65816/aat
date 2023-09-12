load:
	JSL FilterYoshi_load
	RTL

init:
	JSL FilterFireCape_init
	JSL freescrollbabey_init

	; Disable L and R buttons.
	LDA #%00000000 : STA $00
	LDA #%00110000 : STA $01
	JSL DisableButton_main
	RTL
