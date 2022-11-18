


db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

MarioBelow:

	LDA $14AD|!addr
	BEQ Label_0000
	LDA #$1E				; \ Set the blue p-switch timer to #$1E.
	STA $14AD|!addr

Label_0000:
RTL


MarioAbove:
RTL

MarioSide:

SpriteV:
SpriteH:
Cape:
Fireball:
MarioCorner:
MarioBody:
MarioHead:
WallFeet:
WallBody:
RTL




print "P switch will be ended soon"