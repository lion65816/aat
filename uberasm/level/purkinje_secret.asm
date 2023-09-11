load:
	JSL NoStatus_load
	RTL

init:
	JSL freescrollbabey_init
	RTL

main:
	; Disable down and A buttons.
	LDA #%00000100 : STA $00
	LDA #%10000000 : STA $01
	JSL DisableButton_main
	RTL
