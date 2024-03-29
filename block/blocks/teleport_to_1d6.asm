!fixed		= 1		; Teleport to a fixed level? 0 = false, 1 = true.
!screen		= 0		; Teleport to the screen's exit? 0 = false, 1 = true.

!level1		= $01D6		; Change this if needed.
!level2		= $01D9		; Change this if needed.
!secondary	= 0		; Secondary exit? 0 = false, 1 = true.
!water		= 0		; If secondary exit, water level? 0 = false, 1 = true.

db $42
JMP main : JMP main : JMP main
JMP return : JMP return : JMP return : JMP return
JMP main : JMP main : JMP main

main:	
if !fixed
	LDA $0DB3|!addr
	BNE +
	REP #$20
	LDA #!level1|(((!water<<3)|(1<<2)|(!secondary<<1))<<8)
	%teleport()
	BRA return
+
	REP #$20
	LDA #!level2|(((!water<<3)|(1<<2)|(!secondary<<1))<<8)
	%teleport()
else
	if !screen
		LDA #$06
		STA $71
		STZ $88
		STZ $89
	endif
endif
	
return:	RTL

print "Teleports the player to level 1D6 if Demo, and level 1D9 if Iris."
