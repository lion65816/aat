!NumTiles = $0D	;> 13 tiles
!Offset = $0000	;> YYXX

init:
	JSL DisableSideExit_init
	RTL

main:
	JSL freezetimer_main

	; Use the MaxTile system to request OAM slots. Needs SA-1 v1.40.
	LDY.b #$00+(!NumTiles)	;> Request 13 tiles. Input parameter for call to MaxTile.
	REP #$30				;> (As the index registers were 8-bit, this fills their high bytes with zeroes)
	LDA.w #$0000			;> Maximum priority. Input parameter for call to MaxTile.
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
	LDX $3100				;> Main index (16-bit pointer to the OAM general buffer)
	LDY.w #$0000+((!NumTiles-1)*2)	;> Loop index
-
	LDA TileCoord,y		;\ Load tile X and Y coordinates
	CLC					;| Add offset for the entire status bar.
	ADC #!Offset		;|
	STA $400000,x		;/

	LDA TileProps,y		;> Load tile properties.
	STA $400002,x

	INX #4				;\ Move to next slot and loop
	DEY #2				;|
	BPL -				;/

	; OAM extra bits
	LDX $3102			;> Bit table index (16-bit pointer to the OAM attribute buffer)
	LDY.w #$0000+((!NumTiles-2))
-
	LDA TileExtra,y		;\ Store extra bits for two tiles at a time.
	STA $400000,x		;/ 

	INX #2				;\ Loop to set the remaining OAM extra bits.
	DEY #2				;|
	BPL -				;/

	PLB
	RTS

TileCoord:						; YYXX
	dw $9088,$A088,$B088		; Sign post
	dw $8080,$8090,$7080,$7090	; Sign face (bottom) (tile order: down -> up, left -> right)
	dw $6080,$6090,$5080,$5090	; Sign face (top) (tile order: down -> up, left -> right)
	dw $7888,$5888				; Sign icons (bottom to top)
	dw $5888					; (Extra)

TileProps:						; High byte = YXPPCCCT, low byte = tile number
	dw $29C9,$29C9,$29C9		; Sign post
	dw $A9A7,$69C7,$A9C7,$69A7	; Sign face (bottom)
	dw $A9A7,$69C7,$A9C7,$69A7	; Sign face (top)
	dw $29E6,$29EE				; Sign icons (bottom to top)
	dw $29EE					; (Extra)

TileExtra:						; High byte = first tile, low byte = second tile
	dw $0202,$0202,$0202,$0202
	dw $0202,$0202,$0202
