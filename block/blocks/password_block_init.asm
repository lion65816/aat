db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall
JMP TopCorner : JMP BodyInside : JMP HeadInside

print "Password block init"

MarioAbove:
MarioBelow:
MarioSide:

LDA #$00
STA $7F8191
RTL

SpriteV:
SpriteH:
MarioCape:
MarioFireBall:
TopCorner:
HeadInside:
BodyInside:
Return:
	RTL
