;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Break By Fireball Blocks - I8Strudel;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

MarioFireball:
	%shatter_block()
SpriteV:
SpriteH:
MarioCape:
MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
HeadInside:
BodyInside:
	RTL

print "Shatters if a fireball touches it."