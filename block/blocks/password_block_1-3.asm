;> PSI Ninja note: Since we changed $7F8191 to $13E7 (which is cleared on level load), we no longer need password_block_init.asm.

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall
JMP TopCorner : JMP BodyInside : JMP HeadInside

print "Password block 3 for door 1"

MarioAbove:

BRA Return

MarioBelow:

LDA #$0B
STA $1DF9
LDA $13E7|!addr		;> PSI Ninja edit: Changed from $7F8191 to $13E7.
CMP #$02
BEQ Plus
RTL
Plus:
LDA $13E7|!addr		;> PSI Ninja edit: Changed from $7F8191 to $13E7.
CLC
ADC #$01
STA $13E7|!addr		;> PSI Ninja edit: Changed from $7F8191 to $13E7.
RTL

MarioSide:
SpriteV:
SpriteH:
MarioCape:
MarioFireBall:
TopCorner:
HeadInside:
BodyInside:
Return:
	RTL
