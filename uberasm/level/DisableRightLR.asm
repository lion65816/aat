main:
	; Disable right, L, and R buttons.
	LDA #%00000001 : STA $00
	LDA #%00110000 : STA $01
	JSL DisableButton_main
	RTL
