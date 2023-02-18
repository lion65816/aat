


db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

MarioBelow:
MarioAbove:
MarioSide:
SpriteV:
SpriteH:
Cape:
Fireball:
MarioCorner:
RTL

MarioBody:
	%create_smoke()				; > Create smoke effect.
	LDA #$0E				; \ Play the "swim" sound effect.
	STA $1DF9|!addr				; /


MarioHead:
WallFeet:
WallBody:
RTL




print ""