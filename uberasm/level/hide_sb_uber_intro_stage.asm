init:
	JSL hide_sb_uber_init
	RTL

main:
	LDA $71  ; \ Dying
	CMP #$09 ; /
	BNE .return
	LDA #$06		; \ 
	STA $71			; | Teleport Mario
	STZ $89			; | Change if you want (Because it uses the current screen exit dunno if you want that)
	STZ $88			; /
.return
	RTL
