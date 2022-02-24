


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
	LDA #$80				; \ Set the player's y speed to #$80.
	STA $7D					; /
RTL

MarioHead:
	LDA #$80				; \ Set the player's y speed to #$80.
	STA $7D					; /


WallFeet:
WallBody:
RTL




print "A block that will boost the player upwards."