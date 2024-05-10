;;;;;;;;;;;;
; Free RAM ;
;;;;;;;;;;;;

!DeathPointer = $0DDB|!addr		;\ Needed for custom death code.
!HPSettings = $188A|!addr		;/

init:
	; Set up death pointer to the "respawn" label/address.
	LDA.b #Retry     : STA !DeathPointer
	LDA.b #Retry>>8  : STA !DeathPointer+1
	LDA.b #Retry>>16 : STA !DeathPointer+2

	RTL

main:
	LDA #$40			;\ Set bit 6 to activate custom death code (via the Simple HP system). Needs to be done every frame!
	STA !HPSettings		;/

	; Press Start+Select to exit.
	LDA $13D4|!addr					;\ If not paused, then skip.
	BEQ +							;/
	LDA.b $16						;\ If not pressing Select while paused, then skip.
	AND.b #$20						;|
	BEQ +							;/
	PHK								;\ Otherwise, exit the level.
	PEA.w (+)-1						;|
	PEA.w $0084CF-1					;|
    JML $00A269|!bank				;/
+
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Custom death code implementation ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Retry:
	LDA #$FF			;> Restore, some music thing
	JML $00F611			;> Go back to regular death code. Let player farm lives/handle game over.
	RTL
