load:
	JSL NoStatus_load
	LDA #$01			;\ Always keep Demo big.
	STA $19				;/
	LDA #$01			;\ Make player palette grayscale.
	STA $1477|!addr		;/ Handled by global_code.asm.
	RTL

init:
	JSL DisableDeathCounter_init
	JSL freescrollbabey_init
	JSL Layer2Horz_init
	JSL Layer1Vert_init
	RTL

main:
	JSL Layer2Horz_main
	JSL Layer1Vert_main
	STZ $0DC2|!addr		;> Remove item reserve.
	LDA $71				;\ If dying...
	CMP #$09			;/
	BNE .return
	LDA #$06			;\ 
	STA $71				;| ...then teleport Demo.
	STZ $89				;| Change if you want (Because it uses the current screen exit dunno if you want that)
	STZ $88				;/
.return
	RTL
