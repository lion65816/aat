;~@sa1 <-- DO NOT REMOVE THIS LINE!
;Act as $025
;Sets manuel flag to #$01.

incsrc ColorSwitchDef.txt

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

MarioBelow:
	LDA !ManuelTrigger	;\if already pressed, then Return.
	CMP #$01		;|as passable
	BEQ Return		;/
	LDA $7D			;\if player Y speed is going down
	BPL Solid		;/then treat the block as a regular cement block.
Activate:
	LDA #$01		;\set flag.
	STA !ManuelTrigger	;/
	LDA #$0B		;\on/off sfx.
	STA $7DF9		;/
	LDA #$20		;\earthquake effect
	STA $7887		;/
Solid:
	LDY #$01
	LDA #$30
	STA $7693
	RTL

MarioAbove:
MarioSide:
TopCorner:
BodyInside:
HeadInside:
MarioFireball:
SpriteH:
if !SprActivate == 0
SpriteV:
endif
UnpressedSolid:
	LDA !ManuelTrigger	;\Be solid when switch is unpressed
	CMP #$01		;|
	BNE Solid		;/
	RTL
if !SprActivate != 0
SpriteV:
	LDA !ManuelTrigger	;\If switch already pressed, then
	CMP #$01		;|Return as passable
	BEQ Return		;/
	LDA $9E,x		;\act cement if falling
	BPL Solid		;/
	LDA $3242,x		;\If dropped ("you can carry the sprite" state)
	CMP #$09		;|then activate switch
	BNE Solid		;/
	BRA Activate
endif
Return:
MarioCape:
	RTL

print "This button sets a manuel frame value to #$01."