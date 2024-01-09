load:
	JSL NoStatus_load
	RTL

init:
	JSL freescrollbabey_init
	JSL SimpleHP_init
	JSL shmup_init
	RTL

main:
	JSL SimpleHP_main
	JSL shmup_main
	RTL
