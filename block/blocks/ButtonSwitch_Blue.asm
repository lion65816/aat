;~@sa1 <-- DO NOT REMOVE THIS LINE!
;Act as $025
;Sets manuel flag to #$00.

incsrc ColorSwitchDef.txt

db $42
JMP SpringUp : JMP MarioAbove : JMP UnpressedSolid : JMP UnpressedSolid
JMP UnpressedSolid : JMP return : JMP UnpressedSolid : JMP MarioAbove : JMP SpringUp
JMP UnpressedSolid


MarioAbove:
	JSR ReadTrigger	;\if already pressed, then return.
	BEQ return		;/
	LDA $7D			;\if player Y speed is going up
	BMI solid		;/then treat the block as a regular cement block.

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
solid:
	LDY #$01		;\make this block solid if not pressed.
	LDA #$30		;|
	STA $7693		;/
	RTL
UnpressedSolid:
	JSR ReadTrigger	;\solid if not pressed.
	BNE solid		;/
	RTL
SpringUp:
	JSR ReadTrigger	;\if switch pressed, then return.
	BEQ return		;/
	REP #$20		;\move the player out of the unpressed
	LDA $96			;|switch.
	SEC : SBC #$0010	;|
	STA $96			;|
	SEP #$20		;/
return:
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
