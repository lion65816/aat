;shatter for mario and sprites
;by lolcats439

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

SpriteV:
SpriteH:
	%sprite_block_position()
	%shatter_block()
MarioBelow:
MarioAbove:
MarioSide:

TopCorner:
BodyInside:
HeadInside:

MarioCape:
MarioFireball:
	RTL

print "Shatters if any sprite touches it."