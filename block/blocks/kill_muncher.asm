;Block by JackThsSpades
;
;Kills the player instantly regardless of powerup unless he has a star or is riding Yoshi and touches the block from the top
;Pretty much like an instant kill muncher.
;
;Credit? For 14 lines of code? I don't care.

print "Kills Mario unless he has a star or is riding Yoshi"

db $42
JMP Mario : JMP MarioAbove : JMP Mario
JMP Return : JMP Return
JMP Return : JMP Return
JMP MarioAbove : JMP Mario : JMP Mario

MarioAbove:
	LDA $187A|!addr	;Is player riding yoshi? \ remove those two if you want 
	BNE Return	;If yes, skip		 / the block to kill Mario even when on Yoshi
Mario:
	LDA $1490|!addr	;is the star timer set?  \ remove those two if you want
	BNE Return	;if yes, skip		 / the block to kill Mario even when he has starpower
	JSL $00F606|!bank	;if no,...KILL!!!
Return:
	RTL