init:
	JSL Layer2Horz_init
	JSL Layer1Vert_init
	LDA #$01		;\ Set flag for free vertical scroll.
	STA $140B|!addr		;/
	RTL
	

main:
	JSL Layer2Horz_main
	JSL Layer1Vert_main
	;JSL RetryButtonIntro_main	;> Using Retry System instead.
	STZ $0DC2|!addr		;> Remove item reserve.
	LDA #$01		;\ Always keep Demo big.
	STA $19			;/
	LDA #$7F		;\ Make Demo invincible (no power down animation).
	STA $1497|!addr		;/
	RTL

load:
	LDA #$01		;\ Set flag to remove status bar.
	STA $13E6|!addr		;/
	RTL
