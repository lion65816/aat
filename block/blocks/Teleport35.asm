


db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

MarioBelow:
RTL

MarioAbove:
	REP #$20				; \
	LDA #$0035				; | Teleport the player to level #$0035.
	%teleport()				; |
	SEP #$20				; /


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




print ""