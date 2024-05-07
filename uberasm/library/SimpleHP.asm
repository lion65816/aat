;=========================================================
; Example implementation of SimpleHP
; by Lord Ruby
; and edited by PSI Ninja
;
; Note: Be mindful that the graphics code provided here
;       can break if the Y coordinate of the eye origin
;       and max HP combined make the UI go too far below
;       the bottom of the screen. But that's clearly
;       something that should be avoided in the first
;       place anyway.
; Note: Since the UberASM Retry System is being used,
;       we no longer need the Primitive Retry pointers.
;=========================================================

; Defines
!EyeOpenUpperLeftTile = $1CC	;\ Sprite tiles, 000-1FF.
!EyeClosedLeftTile = $1EC	;/ Yes, full tile number, not low byte and high bit separately.
!EyeOrigin = $2808		;> Origin for the HP eyes, YYXX. Note that the top left corner of the screen is 0000.
!InitHP = $03			;\ Level-specific HP settings
!MaxHP = $03			;/

; Free RAM addresses
!HPSettings = $188A|!addr	;\
!HPByte = $58			;| Need to be the same as in the simpleHP.asm patch.
!PowerupResult = $7C		;/

;=================================
; Initialize the HP system
;=================================

init:
	LDA #$80		;\ Set bit 7 to activate the HP system.
	STA !HPSettings		;/ To activate custom death code, set bit 6 as well.

	LDA $19			;\
	BNE .init_hp		;| At the start of the level, retain Demo's powerup.
	LDA #$01		;| Otherwise, if she's small, then start her big.
	STA $19			;/
.init_hp
	LDA #!InitHP		;\ Always start Demo big. For example, avoids issues where Small Demo
	STA !HPByte		;/ phases through the Thwomps at the start of sublevels 2A and 2B.

	RTL

;=================================
; Main routine
;=================================

main:
	LDA !HPByte		;\
	CMP #!MaxHP+1		;| If the current HP is above the maximum...
	BCC +			;/
	LDA #!MaxHP		;\ ...then reset it to the maximum.
	STA !HPByte		;/
+
	LDA !HPByte		;\
	CMP #$02		;| If the HP is below 2...
	BCC .small_demo		;| ...then change to Small Demo.
	LDA !PowerupResult	;| Else, check if Demo has touched a powerup (see simpleHP.asm patch for usage details).
	CMP #$01		;|
	BEQ .get_powerup	;| If she touched a mushroom, make her Big Demo.
	CMP #$02		;|
	BEQ .get_powerup	;| If she touched a feather, make her Cape Demo.
	CMP #$03		;|
	BEQ .get_powerup	;| If she touched a fire flower, make her Fire Demo.
	BRA .check_hurt		;/ Otherwise, retain the powerup she currently has.

.get_powerup
	STA $19
	BRA .check_hurt

.small_demo
	STZ $19

.check_hurt
	BIT !PowerupResult	;\ Check bits of SimpleHP's result byte
	BVC .prepare_draw	;| If bit 6 is set, but bit 7 isn't, Demo has been hurt, else, skip
	BMI .prepare_draw	;/

	; On hurt, cause a very slight stun and prevent flight
	STZ $13E4|!addr		;> Clear run timer (p-meter)
	STZ $149F|!addr		;> Clear flight rise timer
	LDA $72			;\
	CMP #$0C		;| If air state is running jump/flying, set it to normal jump
	BNE +			;|
	DEC $72    		;/
+
	STZ !PowerupResult	;> Clear result byte to let Demo move again

.prepare_draw:
	LDA $71			;\
	CMP #$03		;| Check for get cape animation, which is repurposed as a hurt animation
	CLC			;| ;o:c
	BNE +			;/
	LDA $1496|!addr		;\ Use animation timer to time blinks
	LSR #2			;/ ;o:c
+
	LDA !HPByte		;\ If the last hit point was just lost, make it blink a little
	ADC #$00		;/ ;i:c
	STA $00			;\ Store HP to scratch ram $00, 8 to 16 bit
	STZ $01			;/

	; Use the MaxTile system to request OAM slots. Needs SA-1 v1.40.
	LDY.b #$00+(!MaxHP*3)	;> One eye per hit point, each eye needs three tiles. Input parameter for call to MaxTile.
	REP #$30		;> (As the index registers were 8-bit, this fills their high bytes with zeroes)
	LDA.w #$0000		;> Maximum priority. Input parameter for call to MaxTile.
	JSL $0084B0		;\ Request MaxTile slots (does not modify scratch ram at the time of writing).
				;| Returns 16-bit pointer to the OAM general buffer in $3100.
				;/ Returns 16-bit pointer to the OAM attribute buffer in $3102.
	BCC .return		;\ Carry clear: Failed to get OAM slots, abort.
				;/ ...should never happen, since this will be executed before sprites, but...
	JSR Draw
.return
	SEP #$30
	RTL

;=================================
; Draw HP UI (sprite-based, make
; sure the eye graphics are in the
; appropriate places in SP4)
;=================================

Draw:
	PHB
	PHK
	PLB

	; OAM table
	LDX $3100			;> Main index (16-bit pointer to the OAM general buffer)
	LDY.w #$0000+((!MaxHP-1)*2)	;> Loop index
-
	TYA			;\ Half index to A
	LSR			;/
	CMP $00			;> Compare with current HP. This keeps as many eyes open as Demo has HP. ;o:c
	LDA BaseCoord,y		;\ Load base X and Y coordinates ;i:c
	BCC .open		;/

	; Closed eye coordinates
	ADC.w #$07FF		;\ Left (offsets: Y: 8 (note that carry is set))
	STA $400000,x		;/
	ADC.w #$0008		;\ Middle (offsets: Y: 8, X: 8)
	STA $400004,x		;/
	ADC.w #$0008		;\ Right (offsets: Y: 8, X: 16)
	STA $400008,x		;/

	; Closed eye tiles and properties
	LDA.w #$3000+!EyeClosedLeftTile		;\ Left (highest priority, palette 0, no flip)
	STA $400002,x				;/
	LDA.w #$3001+!EyeClosedLeftTile		;\ Middle (highest priority, palette 0, no flip, one tile to the right)
	STA $400006,x				;/
	LDA.w #$7000+!EyeClosedLeftTile		;> Right (highest priority, palette 0, X flip)
	BRA +

.open:
	; Open eye coordinates
	STA $400000,x		;> Left
	ADC.w #$0010		;\ Top right (offsets: X: 16)
	STA $400004,x		;/
	ADC.w #$0800		;\ Bottom right (offsets: Y: 8, X: 16)
	STA $400008,x		;/

	; Open eye tiles and properties
	LDA.w #$3000+!EyeOpenUpperLeftTile	;\ Left (highest priority, palette 0, no flip)
	STA $400002,x				;/
	LDA.w #$7000+!EyeOpenUpperLeftTile	;\ Top right (highest priority, palette 0, X flip)
	STA $400006,x				;/
	LDA.w #$7010+!EyeOpenUpperLeftTile	;> Bottom right (highest priority, palette 0, X flip, one tile below)
+
	STA $40000A,x

	; Set up the next loop
	TXA			;\
	ADC.w #$000C		;| Increase slot by 3 (4 bytes per slot, so 12).
	TAX			;/
	DEY #2			;\ Loop to draw the remaining eye graphics.
	BPL -			;/

	; OAM extra bits
	LDX $3102		;> Bit table index (16-bit pointer to the OAM attribute buffer)
	LDY.w #$0000+!MaxHP-1	;> Loop index

-
	LDA.w #$0000		;\ Store zero to the second and third tiles
	STA $400001,x		;/
	CPY $00			;\
	BCS +			;| Big (16x16) for open eyes, small (8x8) for closed eyes
	LDA.w #$0002		;| Store zero to second tile, relevant value to first tile
+				;|
	STA $400000,x		;/

	INX #3			;\
	DEY			;| Loop to set the remaining OAM extra bits.
	BPL -			;/

	PLB
	RTS

;=================================
; This loop sets up the data table
; for coordinates
;=================================

BaseCoord:
!counter #= !MaxHP
!tempcoordinate #= !EyeOrigin ;+((!MaxHP-1)*$1000)
while !counter > 0
	dw !tempcoordinate
	!tempcoordinate #= !tempcoordinate+$1000
	!counter #= !counter-1
endif
