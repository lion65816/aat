;Act as $025

!ledge =	0	;>when solid, this block acts like a 1-way up ledge:
			; 0 = false, 1 = true.

incsrc ColorSwitchDef.txt

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

	LDA !ManuelTrigger	;\if corresponding color not match,
	BNE return		;/then return.

	LDY #$01
if !ledge = 0
	LDA #$30
else
	LDA #$00
endif
	STA $7693
return:
RTL

if !ledge = 0
print "Solid if the corresponding switch is activated."
else
print "Ledge if the corresponding switch is activated."
endif
