;;;;;;;;;;;;
; Free RAM ;
;;;;;;;;;;;;

!DeathPointer = $0DDB|!addr		;\ Needed for custom death code.
!HPSettings = $188A|!addr		;/
!RetryRequested = $18D8|!addr	;> Set if the retry button combination was pressed.

;;;;;;;;;;;
; Defines ;
;;;;;;;;;;;

; Note: The mask is now supplied using scratch RAM $00.
; Defines needed for the retry button (pressing L+R).
; Source: teleport_button.asm (part of Teleport Pack by Alcaro and MarioE)
!controller	= $17		; Up, Down, Left, Right, B, X or Y, Start, Select => $16
						; A, X, L, R => $18
!mask		= $30		; Up = $08,	Down = $04,	Left = $02,	Right = $01
						; B = $80,	X or Y = $40,	Select = $20,	Start = $10
						; A = $80,	X = $40,	L = $20,	R = $10

;;;;;;;;
; Code ;
;;;;;;;;

init:
	STZ !RetryRequested

	; Set up death pointer to the "respawn" label/address.
	LDA.b #Retry     : STA !DeathPointer
	LDA.b #Retry>>8  : STA !DeathPointer+1
	LDA.b #Retry>>16 : STA !DeathPointer+2

	RTL

main:
	LDA #$40			;\ Set bit 6 to activate custom death code (via the Simple HP system). Needs to be done every frame!
	STA !HPSettings		;/

	LDA $9D				;\ If the game is paused, then don't check if the player is requesting a retry.
	ORA $13D4|!addr		;|
	BNE +				;/
	LDA !controller		;\ If the player presses the button combination defined in scratch RAM $00,
	AND $00				;| then take a death and retry the current room.
	CMP $00				;| Also, set the retry button combination flag.
	;AND #!mask			;|
	;CMP #!mask			;|
	BNE +				;|
	LDA #$01			;|
	STA !RetryRequested	;|
	JML Retry			;/
+
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Custom death code implementation ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Retry:
	; Play the appropriate death music if the player requested a retry.
	LDA !RetryRequested
	BEQ +
	LDA $0DB3|!addr
	BNE .iris_death
	LDA #$01
	STA $1DFB|!addr
	BRA +
.iris_death
	LDA #$06
	STA $1DFB|!addr
+
	LDA #$FF			;> Restore, some music thing
	JML $00F611			;> Go back to regular death code. Let player farm lives/handle game over.
	RTL
