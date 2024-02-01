load:
	JSL NoStatus_load
	RTL

main:
	LDA #%11111111 : STA $00	;\ Disable all inputs.
	LDA #%11110000 : STA $01	;/
	JSL DisableButton_main
	RTL
