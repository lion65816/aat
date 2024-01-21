load:
	JSL NoStatus_load
	LDA #$01			;\ Always keep Demo big.
	STA $19				;/
	RTL

init:
	JSL DisableDeathCounter_init
	RTL

main:
	JSL GrayscalePalette_main
.return
	RTL
