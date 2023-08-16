;Almost exactly like smw's throw block, but won't disappear when grabbing the layer
;1's block itself. Useful for puzzles, especially for those who doesn't use reset
;doors/pipes. 
;behaves $130
db $42
JMP return : JMP main : JMP main : JMP return : JMP return : JMP return
JMP return : JMP main : JMP main : JMP main

print "Throw block with infinite uses."

!last_timer = $FF	;a timer before the throwblock evaporates at #$03,
			;decrements every 2 frames.

main:
	LDA $16		;\if not pressing dash
	AND #$40	;|
	BEQ return	;/return
	LDA $1470|!addr	;\if already holding something or on yoshi
	ORA $148F|!addr	;|then return.
	ORA $187A|!addr	;|
	BNE return	;/

	LDA #$08				;\"picking something up"
	STA $1498|!addr			;/pose timer
	LDA #$53				;\Spawn throw block
	CLC
	%spawn_sprite()
	TAX
	LDA #$0B		;\carried sprite
	STA !14C8,X		;/ 
	LDA #!last_timer	;\set countdown timer
	STA !1540,x		;|
	STA !C2,x		;/
	LDA !190F,X		;\
	BPL return		;| Something about getting stuck in walls?
	LDA #$10		;|
	STA !15AC,X		;/
	TXA 
	%move_spawn_into_block()
return:
RTL