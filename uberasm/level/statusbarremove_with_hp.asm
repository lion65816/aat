load:
	LDA #$01		;\ Disable the status bar (see remove_statusbar_toggled.asm patch for details).
	STA $13E6|!addr		;/
	RTL

init:
	JSL SimpleHP_init
	RTL

main:
	JSL SimpleHP_main
	RTL
