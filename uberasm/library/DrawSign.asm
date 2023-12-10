; Draw filter signs in level intros as sprite tiles.
; This makes them consistent with the sprite-based No-Yoshi signs.

main:
	; Use the MaxTile system to request OAM slots. Needs SA-1 v1.40.
	LDY.b $00				;> Request a specified number of tiles. Input parameter for call to MaxTile.
	REP #$30				;> (As the index registers were 8-bit, this fills their high bytes with zeroes)
	LDA.w #$0003			;> Lowest priority. Input parameter for call to MaxTile.
	JSL $0084B0				;\ Request MaxTile slots (does not modify scratch ram at the time of writing).
							;| Returns 16-bit pointer to the OAM general buffer in $3100.
							;/ Returns 16-bit pointer to the OAM attribute buffer in $3102.
	BCC .return				;\ Carry clear: Failed to get OAM slots, abort.
							;/ ...should never happen, since this will be executed before sprites, but...
	JSR draw_sign
.return
	SEP #$30
	RTL

;=================================
; Draw filter signs (sprite-based,
; make sure the graphics are in
; the appropriate places in SP4)
;=================================

draw_sign:
	PHB
	PHK
	PLB

	; OAM table
	LDX $3100						;> Main index (16-bit pointer to the OAM general buffer)
	LDA.b $00						;\ Calculate loop index
	DEC								;| and store in Y.
	ASL								;|
	TAY								;/
-
	LDA [$02],y						;\ Load tile X and Y coordinates
	STA $400000,x					;/

	LDA [$05],y						;> Load tile properties.
	STA $400002,x

	INX #4							;\ Move to next slot and loop
	DEY #2							;|
	BPL -							;/

	; OAM extra bits
	LDX $3102						;> Bit table index (16-bit pointer to the OAM attribute buffer)
	LDA.b $00						;\ Calculate loop index
	DEC #2							;| and store in Y.
	TAY								;/
-
	LDA #$0202						;\ Store extra bits for two tiles at a time.
	STA $400000,x					;/ 

	INX #2							;\ Loop to set the remaining OAM extra bits.
	DEY #2							;|
	BPL -							;/

	PLB
	RTS
