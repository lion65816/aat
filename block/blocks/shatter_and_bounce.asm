!bounce_speed	= $C8	;Mario's Y speed after touching the block.
		;Useful notes:
		;#$00-#$7F = falling.
		;#$80-#$FF = rising.
		;#$80 is the highest upwards speed.
		;#$7F is the highest downwards speed.
		;#$46 is the maximum fall speed.
		;#$B3 is the normal jump speed.
		;#$A4 is the jump speed when fully running.

db $42
JMP MAIN : JMP MAIN : JMP MAIN : JMP RETURN : JMP RETURN : JMP RETURN : JMP RETURN
JMP MAIN : JMP MAIN : JMP MAIN

MAIN:
	;LDA $14AF
	;BNE RETURN
	LDA #!bounce_speed
	STA $7D	
	LDA #$0F
	TRB $9A
	TRB $98
	%shatter_block()
RETURN: 
	RTL

print "Shatters and makes the player bounce a bit on player contact."