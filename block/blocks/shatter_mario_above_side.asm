; Based on "shatter for mario" block by lolcats439.

db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

MarioAbove:
MarioSide:
	LDA #$0F
	TRB $9A
	TRB $98   
	%shatter_block()
MarioBelow:
SpriteV:
SpriteH:
MarioCape:
MarioFireball:
TopCorner:
BodyInside:
HeadInside:
	RTL 

print "Shatters if Demo touches it from above or the side."
