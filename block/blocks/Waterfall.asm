;~@sa1 <-- DO NOT REMOVE THIS LINE!
;This block acts like water in which mario goes down faster. Could be used for waterfalls
;Made by Patgangster.

db $42; Enable corner and inside-offsets.
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall : JMP MarioCorner : JMP HeadInside : JMP BodyInside


MarioBelow:
MarioAbove:
MarioSide:
MarioCape:
MarioCorner:
HeadInside:
BodyInside:
	LDA $13
	AND #$03
	CMP #$00
	BNE DONTGODOWNFASTER
        INC $7D	;Mario goes down faster!
DONTGODOWNFASTER:
	LDY #$00	;act like WATUR
	LDA #$02
	STA $7693

SpriteV:
SpriteH:
MarioFireBall:
RTL