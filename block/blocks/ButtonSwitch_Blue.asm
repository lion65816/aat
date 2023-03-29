;Act as $025
;Sets manuel flag to #$00.

incsrc ColorSwitchDef.txt

db $42
JMP SpringUp : JMP MarioAbove : JMP UnpressedSolid : JMP UnpressedSolid
JMP UnpressedSolid : JMP return : JMP UnpressedSolid : JMP MarioAbove : JMP SpringUp
JMP UnpressedSolid


MarioAbove:
	LDA !ManuelTrigger	;\if already pressed, then return.
	BEQ return		;/
	LDA $7D			;\if player Y speed is going up
	BMI solid		;/then treat the block as a regular cement block.

	LDA #$00		;\set flag.
	STA !ManuelTrigger	;/
	LDA #$0B		;\on/off sfx.
	STA $7DF9		;/
	LDA #$20		;\earthquake effect
	STA $7887		;/
solid:
	LDY #$01		;\make this block solid if not pressed.
	LDA #$30		;|
	STA $7693		;/
	RTL
UnpressedSolid:
	LDA !ManuelTrigger	;\solid if not pressed.
	BNE solid		;/
	RTL
SpringUp:
	LDA !ManuelTrigger	;\if switch pressed, then return.
	BEQ return		;/
	REP #$20		;\move the player out of the unpressed
	LDA $96			;|switch.
	SEC : SBC #$0010	;|
	STA $96			;|
	SEP #$20		;/
return:
RTL

print "This button sets a manuel frame value to #$00."