load:
	STZ $14AF|!addr ;Reset On/Off
	RTL

main:
	LDA $71				;\ Skip if not dying.
	CMP #$09			;|
	BNE .return			;/
	if (((read1($0FF0B4)-'0')*100)+((read1($0FF0B4+2)-'0')*10)+(read1($0FF0B4+3)-'0')) > 253
		JSL $03BCDC|!bank
	else
		LDA $5B
		AND #$01
		ASL 
		TAX 
		LDA $95,x
		TAX
	endif

	LDA $0C				;\ adjust what screen exit to use for
	STA $19B8|!addr,x	;| teleporting.
	LDA $0D				;|
	STA $19D8|!addr,x	;/
	LDA #$06			;\ ...then teleport Demo.
	STA $71				;| Change if you want (Because it uses the current screen exit dunno if you want that)
	STZ $89				;|
	STZ $88				;/
	STZ $1496|!addr
	LDA #$20			;\ Play the conventional "Quick Retry" death SFX.
	STA $1DF9|!addr		;/
.return
	RTL
