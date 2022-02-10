;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Break By Cape Blocks - I8Strudel;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

MarioCape:
	%shatter_block()
SpriteV:
SpriteH:
MarioFireball:
MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
HeadInside:
BodyInside:
	RTL

print "Shatters if Mario's cape touches it."