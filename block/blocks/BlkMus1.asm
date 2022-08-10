db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP HeadInside : JMP BodyInside

!Slot = $67

MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
HeadInside:
BodyInside:
lda #!Slot
sta $7dfb
rtl
SpriteV:
SpriteH:
MarioCape:
MarioFireball:
rtl