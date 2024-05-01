; replaces the P-Switch music with a ticking sound effect while keeping the normal music playing
; by Kil
; PSI Ninja edit: Added directional coin ticking, SA-1 support, and changed the main code hijack.

	!700000 = $700000
	!addr = $0000
if read1($00FFD5) == $23
	sa1rom
	!700000 = $41C000
	!addr = $6000
endif

!PSwitchSFX = $2D

org $008DAC
	autoclean JSL MAIN_CODE
	NOP

org $00C54C
	NOP #3			; This used to change the music back after the p switch finished.
				; We don't want this to happen anymore.

freecode

MAIN_CODE:
	STZ $2115		; (Restored code from hacked routine)
	LDA #$42		; (Restored code from hacked routine)
	
	PHP			;
	PHB			;
	PHY			;  Push some stuff
	PHX			;
	PHA			;

	LDA $14AD|!addr		;  Check the blue p switch timer
	AND #$0F
	CMP #$0F
	BNE CHECKSILVER		; Every time the first 5 bits are 1, it plays the sound.
	LDA #!PSwitchSFX	;
	STA $1DF9|!addr		;

CHECKSILVER:
	LDA $14AE|!addr		; Check the silver p switch timer
	AND #$0F
	CMP #$0F
	BNE CHECKDIRECTIONAL	; Every time the first 5 bits are 1, it plays the sound.
	LDA #!PSwitchSFX	;
	STA $1DF9|!addr		;

CHECKDIRECTIONAL:
	LDA $190C|!addr		; Check the directional coin timer
	AND #$0F
	CMP #$0F
	BNE RETURN		; Every time the first 5 bits are 1, it plays the sound.
	LDA #!PSwitchSFX	;
	STA $1DF9|!addr		;

RETURN:
	PLA			;  
	PLX			;
	PLY			;  Pull some stuff
	PLB			;
	PLP			;

	RTL
END_CODE:
