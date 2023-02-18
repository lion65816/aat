init:
	JSL Layer2Horz_init
	JSL Layer1Vert_init

	RTL
	

main:
	JSL Layer2Horz_main
	JSL Layer1Vert_main
	;JSL RetryButtonIntro_main	;> Using Retry System instead.
	STZ $0DC2|!addr
	LDA $19		;\ Check, if Mario is small
	BEQ .small	;/
	RTL
	
	.small
	INC $19		;  Increase powerup
	RTL

load:
    lda #$01
    sta $13E6|!addr
    rtl
