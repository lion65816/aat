


db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

MarioBelow:
	LDA #$22				; \ Play the "message box/save prompt" sound effect.
	STA $1DFC|!addr				; /
	LDA #$5C				; \
	STA $13BF|!addr				; | Display level 138's second message.
	LDA #$02				; |
	STA $1426|!addr				; /
	%create_smoke()				; > Create smoke effect.
	PHY					; \
	LDA #$02				; | Erase the current block.
	STA $9C					; |
	JSL $00BEB0				; |
	PLY					; /


MarioAbove:
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