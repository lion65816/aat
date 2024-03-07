load:
	JSL NoStatus_load
	LDA #$01			;\ Always keep Demo big.
	STA $19				;/
	LDA #$01			;\ Make player palette grayscale.
	STA $1477|!addr		;/ Handled by global_code.asm.
	RTL

init:
	JSL DisableDeathCounter_init
	RTL
