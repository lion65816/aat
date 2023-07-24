init:
	JSL Layer2Horz_init
	JSL Layer1Vert_init
	RTL
	

main:
	JSL Layer2Horz_main
	JSL Layer1Vert_main
	;JSL RetryButtonIntro_main	;> Using Retry System instead.
	STZ $0DC2|!addr		;> Remove item reserve.
	LDA $71  ; \ Dying
	CMP #$09 ; /
	BNE .return
	LDA #$06		; \ 
	STA $71			; | Teleport Mario
	STZ $89			; | Change if you want (Because it uses the current screen exit dunno if you want that)
	STZ $88			; /
.return
	RTL

load:
	LDA #$01		;\ Set flag to remove status bar.
	STA $13E6|!addr		;/
	LDA #$01		;\ Always keep Demo big.
	STA $19			;/

	RTL
