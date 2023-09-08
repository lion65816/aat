load:
	LDA #$02		;\ Enable the minimal status bar (see retry_config/extra.asm for details).
	STA $13E6|!addr		;/
	RTL
