; Needs to be the same free RAM address as specified in the deathcounter.asm patch.
!freeram = $18BB|!addr

init:
	LDA #$01
	STA !freeram
	RTL
