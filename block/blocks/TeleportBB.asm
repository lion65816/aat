


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
	LDA #$06				; \ Play the "yoshi gulp" sound effect.
	STA $1DF9|!addr				; /
	REP #$20				; \
	LDA #$00BB				; | Teleport the player to level #$00BB.
	%teleport()				; |
	SEP #$20				; /


MarioHead:
WallFeet:
WallBody:
RTL




print ""