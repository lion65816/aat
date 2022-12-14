!act		= $0025		; Change this if needed.
!switch		= $14AF		; $14AD = Blue P-Switch,	$14AE = Silver P-Switch
				; $14AF = ON/OFF Switch,	$1F27 = Green Switch
				; $1F28 = Yellow Switch,	$1F29 = Blue Switch
				; $1F2A = Red Switch
!reversed	= 0		; Reversed conditions? 0 = false, 1 = true.

db $37
JMP main : JMP main : JMP main : JMP main : JMP main : JMP main : JMP main
JMP main : JMP main : JMP main : JMP main : JMP main

if !switch == $14AF
	!inverted = 1
else
	!inverted = 0
endif

main:	LDA !switch|!addr
if !reversed^!inverted
	BNE .return
else
	BEQ .return
endif
	
	LDY.b #!act>>8
	LDA.b #!act
	STA $1693|!addr
	
.return	RTL

if !reversed
	print "Acts as ", hex(!act), " if a specific switch isn't active."
else
	print "Acts as ", hex(!act), " if a specific switch is active."
endif