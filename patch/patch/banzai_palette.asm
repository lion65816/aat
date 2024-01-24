; Use different Banzai Bill palettes depending on the level.
; Patch by PSI Ninja.

sa1rom

!addr = $6000
!bank = $000000

org $02D608|!bank
	autoclean JSL banzai_palette

freecode

banzai_palette:
	PHA
	LDA $13BF|!addr
	CMP #$07
	BNE +
	PLA
	ORA #$02			;> If Level 7, use palette row F.
	STA $0303|!addr,y
	BRA ++
+
	PLA
++
	INY #4				;> Original code.
	RTL
