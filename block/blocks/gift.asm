print "A block that, when touched by the player, will change the background music to a new value and then destroy itself."

!SFXFade = $2E			;the number of the VolumeFade sound effect
!SFXPort = $1DF9		;the port that the above sound effect is available at

db $42
JMP Main : JMP Main : JMP Main
JMP Return : JMP Return : JMP Return : JMP Return
JMP Main : JMP Main : JMP Main

Main:


	LDA #!SFXFade		
	STA !SFXPort|!addr
	
	;LDA #$FF	;course clear
	;STA $1493|!addr	;mode

	%erase_block()

Return:
	RTL