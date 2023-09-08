load:
	LDA #$01		;\ Disable the status bar (see retry_config/extra.asm for details).
	STA $13E6|!addr		;/
	RTL
