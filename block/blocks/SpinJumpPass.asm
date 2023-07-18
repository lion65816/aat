print "Can't pass unless spinjumping"

db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
BodyInside:
HeadInside:
LDA $140D|!addr
BEQ +
LDA.b #$25
LDY.b #$00
;WallFeet:    ; when using db $37
;WallBody:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
+
RTL