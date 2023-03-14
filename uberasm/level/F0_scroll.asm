init:
	JSL onoff_init
	JSL onoff_scroll_init
	RTL

main:
	JSL onoff_main
	JSL onoff_scroll_main
	RTL

load:
	JSL FilterYoshi_load
	RTL
