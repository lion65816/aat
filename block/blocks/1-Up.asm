; Act as $025.

db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
BodyInside:
HeadInside:
WallFeet:
WallBody:
	; Note: The 1-up score sprite is responsible for making the "1 up" text
	; appear, playing the sound, and increasing the lives counter.
	LDA #$0D				;> 1-up score sprite
	%process_powerup() : BCC Return		;\If there is collision
	%erase_block()				;/Then erase block

SpriteV:
SpriteH:
MarioCape:
MarioFireball:
Return:
	RTL

print "Same as the 1-up sprite."
