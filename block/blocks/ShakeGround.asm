;~@sa1 <-- DO NOT REMOVE THIS LINE!



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
	LDA #$25				; \ Play the "blargg roar" sound effect.
	STA $7DF9|!addr				; /
	LDA #$00				; \ Shake the ground for 0 frames.
	STA $7887|!addr				; /


MarioHead:
WallFeet:
WallBody:
RTL




print ""