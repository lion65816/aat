!deathtype		=	1		;0 = sprite disappears without SFX
!killIfCarried		=	1		;1 = kill the sprite if it gets carried
!playSFX		=	1		;1 = play a SFX when !deathtype is 1
!sfx			=	$20		;sfx to play
!sfxBank		= 	$1DFC
db $37
JMP Return : JMP Return : JMP Return : JMP Sprite
JMP Sprite : JMP Return : JMP Return : JMP Return
JMP Return : JMP Return : JMP Return : JMP Return
Sprite:
if !killIfCarried == 0
	LDA !14C8,x
	CMP #$0B
	BEQ Return
endif
if !deathtype == 0
	STZ !14C8,x
else
	LDA #$05	;\ (PSI Ninja edit)
	STA !14C8,x	;| Kill the sprite as if by lava.
	LDA #$40	;| SFX above are changed appropriately.
	STA !1558,x	;/
	if !playSFX
	LDA #!sfx
	STA !sfxBank|!addr	
	endif
endif
Return:
RTL
print "Sprites touching this block will die as if by lava."
