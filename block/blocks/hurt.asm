


db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

MarioBelow:
	PHY : JSL $00F5B7 : PLY			; > Hurt the player.
RTL

MarioAbove:
	PHY : JSL $00F5B7 : PLY			; > Hurt the player.
RTL

MarioSide:
	PHY : JSL $00F5B7 : PLY			; > Hurt the player.
RTL

SpriteV:
	LDA #$04				; \
	STA !14C8,X				; |
	LDA #$1F				; | Kill the sprite as if spin-jumping it.
	STA !1540,X				; |
	JSL $07FC3B				; |
	LDA #$08				; |
	STA $1DF9|!addr				; /
RTL

SpriteH:
	LDA #$04				; \
	STA !14C8,X				; |
	LDA #$1F				; | Kill the sprite as if spin-jumping it.
	STA !1540,X				; |
	JSL $07FC3B				; |
	LDA #$08				; |
	STA $1DF9|!addr				; /


Cape:
Fireball:
MarioCorner:
MarioBody:
MarioHead:
WallFeet:
WallBody:
RTL




print ""