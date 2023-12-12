;~@sa1 <-- DO NOT REMOVE THIS LINE!
;Act as $025

!ledge =	0	;>when solid, this block acts like a 1-way up ledge:
			; 0 = false, 1 = true.

;incsrc ColorSwitchDef.txt

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV
JMP SpriteH : JMP return : JMP MarioFireBall : JMP MarioAbove
JMP BodyInside : JMP HeadInside

BodyInside:
MarioAbove:
MarioSide:
HeadInside:
MarioBelow:
SpriteV:
SpriteH:
MarioFireBall:

	STZ $00						;Clear scratch ram
	;Invoke SNES instead
	LDA.b #Main		: STA $0183	;Bank
	LDA.b #Main>>8	: STA $0184	;High byte
	LDA.b #Main>>16	: STA $0185	;Low byte
	LDA #$D0		: STA $2209	;Invoke SNES
	.wait
	LDA $018A : BEQ .wait		;Wait until SNES sets this address
	STZ $018A

	LDY $00						;High byte "act as"

return:
RTL

Main:
	LDA $7FC076	;\if corresponding color not match,
	;CMP #$01		;|then return.
	BNE return		;/

	LDA #$01 : STA $00	;Record Y value in scratch ram
if !ledge = 0
	LDA #$30
else
	LDA #$00
endif
	STA $7693
RTL

if !ledge = 0
print "Solid if the corresponding switch is activated."
else
print "Ledge if the corresponding switch is activated."
endif

