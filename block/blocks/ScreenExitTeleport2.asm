db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

MarioBelow:
RTL

MarioAbove:
	LDA #$06				; \
	STA $71					; | Teleport the player via screen exit.
	STZ $88					; |
	STZ $89					; /

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

print "Teleport the player via screen exit."
