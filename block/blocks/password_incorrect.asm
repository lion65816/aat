; Keeps track of password inputs.
; Must be the same free RAM as in the abcd.asm UberASM file.
!FreeRAM = $13E7|!addr

db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall
JMP TopCorner : JMP BodyInside : JMP HeadInside

MarioAbove:
	BRA Return
MarioBelow:
	STZ !FreeRAM	;> Invalidate password if Demo hits this block.
MarioSide:
SpriteV:
SpriteH:
MarioCape:
MarioFireBall:
TopCorner:
HeadInside:
BodyInside:
Return:
	RTL

print "Incorrect password block."
