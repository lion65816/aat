init:
	JSL gradient_whales_init
	RTL

main:
	; Disable L and R buttons.
	LDA #%00000000 : STA $00
	LDA #%00110000 : STA $01
	JSL DisableButton_main
	RTL
