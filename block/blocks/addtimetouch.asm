db $42

!Time = $014	; Time to add. You can put any 16-bit value here if you want.
!Sound = $29	; Sound to play.

JMP Below : JMP Below : JMP Below
JMP Return : JMP Return : JMP Return : JMP Return
JMP Below : JMP Return : JMP Return

print "Adds ",dec(!Time)," seconds to the clock and shatters"

Below:
	REP #$20
	LDA.w #!Time
	CMP.w #$03E7
	BCS AddMax
	SEP #$20
 
	LDA #!Sound
	STA $1DFC	; If you would like, change it to $1DF9.

	JSR ConvertTime
	CLC
	ADC.w #!Time
	CMP.w #$03E8
	BCC Normal
AddMax:
	SEP #$20
	LDA #$09
	STA $0F31
	STA $0F32
	STA $0F33
	JSR Shatter
Return:
	RTL

Normal:
	REP #$30
	LDY #$0000
	LDX #$0000

Loop1:
	CMP.w #$0064
	BCC Loop2
	SBC.w #$0064
	INY
	BRA Loop1

Loop2:	
	CMP.w #$000A
	BCC SetTime
	SBC.w #$000A
	INX
	BRA Loop2

SetTime:
	SEP #$30
	STY $0F31
	STX $0F32
	STA $0F33
	JSR Shatter
	RTL

ConvertTime:
	LDA $0F32	;get tens count
	STA $4202
	LDA #10
	STA $4203
	
	LDA $0F33	;ones count plus...
	CLC		;carry need only be cleared one time
	ADC $4216	;...tens count

	LDY $0F31	;hundreds count
	STY $4202
	LDY #100
	STY $4203

	REP #$20
	AND.w #$00FF	;get rubbish out of high byte
	ADC $4216

	RTS

Shatter:
	%shatter_block()
	RTS