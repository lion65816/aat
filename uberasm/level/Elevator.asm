load:
	JSL NoStatus_load
	RTL

main:
	; Disable all buttons except "up".
	LDA #%11110111 : STA $00
	LDA #%11110000 : STA $01
	JSL DisableButton_main

	; Always press "up".
	LDA #%00001000
	TSB $15
	TSB $16
	RTL
