print "A block that, when touched by the player, will change the background music to a new value and then destroy itself."

!SFXFade = $9B			;the number of the VolumeFade sound effect
!SFXPort = $1DFB		;the port that the above sound effect is available at

!freeram = $18CC|!addr	; Free RAM flag to only show the message once per level.

db $42
JMP Main : JMP Main : JMP Main
JMP Return : JMP Return : JMP Return : JMP Return
JMP Main : JMP Main : JMP Main

Main:
	LDA !freeram	;\ Skip if free RAM is already set.
	BNE Return		;/

	LDA #!SFXFade		
	STA !SFXPort|!addr

	LDA #$FF	;course clear
	STA $1493|!addr	;mode

	; Load player-specific message.
	LDA $0DB3|!addr
	BNE .iris
	LDA #$01
	BRA +
.iris
	LDA #$02
+
	STA $1426|!addr
	LDA #$01
	STA !freeram

	%erase_block()

Return:
	RTL
