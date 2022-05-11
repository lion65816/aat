!deathtype		=	1		;0 = sprite disappears without SFX
!killIfCarried	=	1		;1 = kill the sprite if it gets carried
!playSFX		=	1		;1 = play a SFX when !deathtype is 1
!sfx			=	$08		;sfx to play
!sfxBank		= 	$1DF9
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
	LDA #$04
	STA !14C8,x
	PHY
	JSL $07FC3B
	PLY
	if !playSFX
	LDA #!sfx
	STA !sfxBank|!addr	
	endif
endif
Return:
RTL
print "Sprites touching this block will die."