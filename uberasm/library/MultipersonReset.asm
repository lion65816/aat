
main:
	LDA $71				;\ If dying...
	CMP #$09			;/
	BNE .return
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

	LDA $0C	;\adjust what screen exit to use for
	STA $19B8|!addr,x		;|teleporting.
	LDA $0D	;|
	STA $19D8|!addr,x		;/
	LDA #$06			;\ 
	STA $71				;| ...then teleport Demo.
	STZ $89				;| Change if you want (Because it uses the current screen exit dunno if you want that)
	STZ $88				;/
.return
	RTL
