init:
	JSL DisableDeathCounter_init
	JSL DeathWarp_init
	RTL

main:
	JSL DeathWarp_main
	RTL

load:
	JSL FilterYoshi_load
	RTL
