load:
	;JSL NoStatus_load
	RTL

init:
	;JSL hide_sb_uber_init
	JSL SimpleHP_init
	JSL shmup_init
	RTL

main:
	JSL SimpleHP_main
	JSL BossHPLevelD_main
	JSL shmup_main
	JSL BG_AutoScroll1CC_main
	RTL
