


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
	LDA #$01				; \ Make the current level a slippery level.
	STA $86					; /


MarioHead:
WallFeet:
WallBody:
RTL




print ""