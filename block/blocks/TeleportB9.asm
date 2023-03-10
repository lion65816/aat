


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
	REP #$20				; \
	LDA #$00B9				; | Teleport the player to level #$00B9.
	%teleport()				; |
	SEP #$20				; /


MarioHead:
WallFeet:
WallBody:
RTL




print ""