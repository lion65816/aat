


db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

MarioBelow:
	LDA #$22				; \ Set the blue p-switch timer to 50.
	STA $14AD|!addr				; /


MarioAbove:
RTL

MarioSide:
	LDA #$22				; \ Set the blue p-switch timer to 50.
	STA $14AD|!addr				; /


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