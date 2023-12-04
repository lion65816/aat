; Allow the palette of the Falling Spike to be changed.
; Patch by PSI Ninja.

sa1rom

!addr = $6000
!bank = $000000
!9E = $3200		;> Sprite number table.
!15F6 = $33B8	;> Sprite YXCCPPPT table.

org $01E343|!bank
	autoclean JSL mole_palette

freecode

mole_palette:
	LDA !15F6,x		;\ Use palette A instead of
	ORA #$04		;| palette 8 for the mole.
	STA !15F6,x		;/
	LDA !9E,x		;\ Original code.
	CMP #$4D		;/
	RTL
