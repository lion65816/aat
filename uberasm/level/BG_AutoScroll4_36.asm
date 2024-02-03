main:
	JSL BG_AutoScroll4_main
	LDA $71				;\ If dying...
	CMP #$09			;/
	BNE .return
	LDA #$06			;\ 
	STA $71				;| ...then teleport Demo.
	STZ $89				;| Change if you want (Because it uses the current screen exit dunno if you want that)
	STZ $88				;/
	.return
	RTL
