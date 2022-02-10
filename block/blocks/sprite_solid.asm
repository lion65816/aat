;This block will act just like normal for sprites, but act like a different block for Mario
;(by default it's the blank tile 0025)
;This can be used to easily make blocks, slopes and ledges that are only solid for sprites
;by assigning this block to multiple map16 tiles and changing their acts like in Lunar Magic


!FireballRules	= 0	;Should Mario's fireballs follow the same rules as Mario?    (0=No)
!YoshiRules	= 0	;Should Yoshi and Baby Yoshi follow the same rules as Mario? (0=No)
!ActsLike	= $0025	;Acts Like number which should be used for Mario block interactions



db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
JMP WallFeet : JMP WallBody


if !YoshiRules == 1
SpriteV: : SpriteH:
LDA !9E,x
CMP #$2D
BEQ MarioBelow
CMP #$35
BNE +
endif

MarioBelow: : MarioAbove: : MarioSide:
TopCorner: : BodyInside: : HeadInside:
WallFeet: : WallBody:
MarioCape:

if !FireballRules == 1
MarioFireball:
endif

LDY.b #!ActsLike>>8
LDA.b #!ActsLike
STA $1693|!addr

if !YoshiRules == 0
SpriteV: : SpriteH:
endif

if !FireballRules == 0
MarioFireball:
endif

+
RTL

if !YoshiRules && !FireballRules == 1
print "A block that will act like tile ",hex(!ActsLike)," for Mario, Mario's fireballs, Yoshi and Baby Yoshi"
elseif !YoshiRules
print "A block that will act like tile ",hex(!ActsLike)," for Mario, Yoshi and Baby Yoshi"
elseif !FireballRules
print "A block that will act like tile ",hex(!ActsLike)," for Mario and Mario's fireballs"
else
print "A block that will act like tile ",hex(!ActsLike)," for Mario"
endif