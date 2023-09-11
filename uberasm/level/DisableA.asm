main:
	; Disable A button.
	LDA #%00000000 : STA $00
	LDA #%10000000 : STA $01
	JSL DisableButton_main
	RTL
