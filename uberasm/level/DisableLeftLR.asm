main:
	; Disable left, L, and R buttons.
	LDA #%00000010 : STA $00
	LDA #%00110000 : STA $01
	JSL DisableButton_main
	RTL
