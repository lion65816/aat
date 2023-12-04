; Allow the palette of the Falling Spike to be changed.
; Patch by PSI Ninja.

sa1rom

!addr = $6000
!bank = $000000

org $03921B|!bank
	autoclean JSL falling_spike_palette
	NOP

freecode

falling_spike_palette:
	LDA #$E0			;\ Original code.
	STA $0302|!addr,y	;/
	LDA #$45			;\ Use palette A instead of palette 8.
	STA $0303|!addr,y	;/
	RTL
