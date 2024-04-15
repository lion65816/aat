!fixed		= 1		; Teleport to a fixed level? 0 = false, 1 = true.
!screen		= 0		; Teleport to the screen's exit? 0 = false, 1 = true.

!controller	= $16		; Up, Down, Left, Right, B, X or Y, Start, Select => $16
				; A, X, L, R => $18
!mask		= $C0		; Up = $08,	Down = $04,	Left = $02,	Right = $01
				; B = $80,	X or Y = $40,	Select = $20,	Start = $10
				; A = $80,	X = $40,	L = $20,	R = $10

!level		= $001A		; Change this if needed.
!secondary	= 1		; Secondary exit? 0 = false, 1 = true.
!water		= 0		; If secondary exit, water level? 0 = false, 1 = true.

db $42
JMP main : JMP main : JMP main
JMP return : JMP return : JMP return : JMP return
JMP main : JMP main : JMP main

main:	LDA !controller
	AND #!mask
	BEQ return
	
if !fixed
	REP #$20
	LDA #!level|(((!water<<3)|(1<<2)|(!secondary<<1))<<8)
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

print "Teleports the player if a specific button is pressed."