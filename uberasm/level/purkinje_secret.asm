load:
	JSL NoStatus_load
	LDA #$02
	STA $1477|!addr
	RTL

init:
	JSL freescrollbabey_init
	RTL

main:
	;JSL InvertPalette_main
	; Disable down and A buttons.
	LDA #%00000100 : STA $00
	LDA #%10000000 : STA $01
	JSL DisableButton_main
	RTL
