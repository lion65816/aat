;=========================================================
; Example implementation of BossHP
; by Lord Ruby
; and edited by PSI Ninja
;=========================================================

; Defines
!BossHPTile = $1E6		;\ Sprite tiles, 000-1FF.
!BossNoHPTile = $1E8		;/ Yes, full tile number, not low byte and high bit separately.
!HPOrigin = $07E8		;> Origin for the HP eyes, YYXX. Note that the top left corner of the screen is 0000.
!BossMaxHP = $40		;> Needs to be the same as in the demoka_boss.asm file.
!BossMaxHPTiles = !BossMaxHP/8	;> Each tile represents 8 HP (!BossMaxHP needs to be a multiple of 8).

;BossHPTiles:
;	dw $00C0,$00C2,$00C4,$00C6,$00C8,$00CA,$00CC,$00CE

; Free RAM addresses
!BossCurrentHP = $18C5|!addr	;> Needs to be the same as in the demoka_boss.asm file.

;=================================
; Main routine
;=================================

main:
	LDA !BossCurrentHP
	STA $00
	AND #$07
	STA $01
	STA $0DBF|!addr		;> [[[[[DEBUG]]]]]
	LDA $00
	LSR #3
	STA $00
	LDA $01
	BEQ +
	INC $00
+

	; Use the MaxTile system to request OAM slots. Needs SA-1 v1.40.
	LDY.b #$00+(!BossMaxHPTiles)	;> One tile per boss HP. Input parameter for call to MaxTile.
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
; sure the HP graphics are in the
; appropriate places in SP4)
;=================================

Draw:
	PHB
	PHK
	PLB

	; OAM table
	LDX $3100				;> Main index (16-bit pointer to the OAM general buffer)
	LDY.w #$0000+((!BossMaxHPTiles-1)*2)	;> Loop index
-
	TYA			;\ Half index to A
	LSR			;/
	CMP $00			;> Compare with current HP. This keeps as many eyes open as Demo has HP. ;o:c
	LDA BossHPCoord,y	;\ Load base X and Y coordinates ;i:c
	STA $400000,x		;/

	; Tiles and properties (highest priority, no flip; palette and tile below)
	LDA.w #$3000+!BossHPTile
	BCC +					;> If the loop index (halved) is less than the current boss HP, then print the "no HP" tile. ;i:c
	LDA.w #$3000+!BossNoHPTile
+
	STA $400002,x		;> Store to MaxTile

	INX #4			;\
	DEY #2			;| Move to next slot and loop
	BPL -			;/

	; OAM extra bits
	LDX $3102			;> Bit table index (16-bit pointer to the OAM attribute buffer)
	LDY.w #$0000+(!BossMaxHPTiles)/2-1	;> Loop index (assumes even max HP)
	LDA.w #$0202			;> Big (16x16) for both tiles
-
	STA $400000,x			;> Store to both

	INX #2			;\
	DEY			;| Loop to set the remaining OAM extra bits.
	BPL -			;/

	PLB
	RTS

;=================================
; This loop sets up the data table
; for coordinates
;=================================

; Note: Commented out math reverses HP UI directions
BossHPCoord:
!counter #= !BossMaxHPTiles
!tempcoordinate #= !HPOrigin	;-((!BossMaxHPTiles-1)*$0012)
while !counter > 0
	dw !tempcoordinate
	!tempcoordinate #= !tempcoordinate-$0012
	!counter #= !counter-1
endif
