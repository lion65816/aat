;~@sa1 <-- DO NOT REMOVE THIS LINE!
;Act as $025
;Sets manuel flag to #$00.

incsrc ColorSwitchDef.txt

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

MarioBelow:
	JSR ReadTrigger	;\if already pressed, then Return.
	BEQ Return		;/as passable
	LDA $7D			;\if player Y speed is going down
	BPL Solid		;/then treat the block as a regular cement block.
Activate:
	;Call WriteTrigger on SNES
	LDA.b #WriteTrigger		: STA $0183	;Bank
	LDA.b #WriteTrigger>>8	: STA $0184	;High byte
	LDA.b #WriteTrigger>>16	: STA $0185	;Low byte
	LDA #$D0				: STA $2209	;Invoke SNES
	.wait
	LDA $018A : BEQ .wait				;Wait until SNES sets this address
	STZ $018A

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
	JSR ReadTrigger	;\Be solid when switch is unpressed
	BNE Solid		;/
	RTL
if !SprActivate != 0
SpriteV:
	JSR ReadTrigger	;\If switch already pressed, then
	BEQ Return		;/Return as passable
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

ReadTrigger:
	;Invoke SNES
	LDA.b #.snes		: STA $0183	;Bank
	LDA.b #.snes>>8		: STA $0184	;High byte
	LDA.b #.snes>>16	: STA $0185	;Low byte
	LDA #$D0			: STA $2209	;Invoke SNES
	.wait
	LDA $018A : BEQ .wait			;Wait until SNES sets this address
	STZ $018A

	;Read trigger
	LDA $00
RTS

.snes
	LDA !ManuelTrigger : STA $00	;sic. Copies trigger to scratch (I) RAM.
RTL

WriteTrigger:
	LDA #$00 : STA !ManuelTrigger	;sic. Writes color to trigger.
RTL

print "This button sets a manuel frame value to #$00."
