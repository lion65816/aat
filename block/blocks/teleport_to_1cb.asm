!fixed		= 1		; Teleport to a fixed level? 0 = false, 1 = true.
!screen		= 0		; Teleport to the screen's exit? 0 = false, 1 = true.

!level		= $01CB		; Change this if needed.
!secondary	= 0		; Secondary exit? 0 = false, 1 = true.
!water		= 0		; If secondary exit, water level? 0 = false, 1 = true.

db $42
JMP main : JMP main : JMP main
JMP return : JMP return : JMP return : JMP return
JMP main : JMP main : JMP main

main:	
if !fixed
	REP #$20
	LDA #!level|(((!water<<3)|(1<<2)|(!secondary<<1))<<8)
	%teleport()
endif
	
return:	RTL

print "Teleports the player to level 1CB."
