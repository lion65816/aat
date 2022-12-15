init:
	JSL onoff_init
	JSL onoff_scroll_init
    LDA #$01
    STA $140B|!addr
	RTL

main:
	JSL onoff_main
	JSL onoff_scroll_main
	RTL