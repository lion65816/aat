;> PSI Ninja note: Since we changed $7F8191 to $13E7 (which is cleared on level load), we no longer need password_block_init.asm.

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall
JMP TopCorner : JMP BodyInside : JMP HeadInside

print "Password door number 1"

MarioAbove:
MarioBelow:
MarioSide:

LDA $13E7|!addr		;> PSI Ninja edit: Changed from $7F8191 to $13E7.
CMP #$05		;> PSI Ninja edit: Changed from #$07 to #$05.
BNE Wrong
LDA $15
AND #$08
BEQ Return
LDA #$0F
STA $1DFC|!addr		;> PSI Ninja edit: SA-1 compatibility.
LDA #$06
STA $71
RTL
Wrong:
LDA #$2A
STA $1DFC|!addr		;> PSI Ninja edit: SA-1 compatibility.
LDA #$01
STA $13E7|!addr		;> PSI Ninja edit: Changed from $7F8191 to $13E7.

SpriteV:
SpriteH:
MarioFireBall:
MarioCape:
TopCorner:
HeadInside:
BodyInside:
Return:
RTL
