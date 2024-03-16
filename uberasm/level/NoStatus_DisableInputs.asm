load:
	JSL NoStatus_load
	RTL

main:
	LDA #$7F	;\ Make the player invisible.
	STA $78		;/ Source: https://www.smwcentral.net/?p=section&a=details&id=22636

	LDA #%11111111 : STA $00	;\ Disable all inputs.
	LDA #%11110000 : STA $01	;/
	JSL DisableButton_main
	RTL
