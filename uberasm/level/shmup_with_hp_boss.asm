load:
	JSL MinStatus_load
	RTL

init:
	JSL SimpleHP_init
	JSL shmup_init
	JSL fastbgscroll_init
	RTL

main:
	JSL SimpleHP_main
	JSL BossHPLevelD_main
	JSL shmup_main
	JSL fastbgscroll_main

	; Disable select button.
	LDA #%00100000 : STA $00
	LDA #%00000000 : STA $01
	JSL DisableButton_main
	RTL
