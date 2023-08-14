init:
	JSL SimpleHP_init
	JSL shmup_init
	RTL

main:
	JSL SimpleHP_main
	JSL shmup_main
	JSL BG_AutoScroll1CC_main
	RTL
