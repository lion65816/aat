; Print overworld map names as sprite tiles.
; Patch by PSI Ninja.

sa1rom

!addr = $6000
!bank = $000000

!NumTiles = $08		;> 8 16x16 tiles
!TileOrigin = $0770	;> Reference coordinate (YYXX)
!TileProp = $3E00	;> High byte contains the YXPPCCCT

; Hijack routine that draws the overworld border.
; Source: https://smwc.me/866356
org $0485E8|!bank
	autoclean JSL overworld_map_names

freecode

;=================================
; Main routine
;=================================

overworld_map_names:
	; Determine which row of logos to load (relevant for the main map).
	STZ $03				;\ By default, the offset is zero (first row).
	STZ $04				;/
	LDA $0DDA|!addr		;> Base the offset on the music currently playing on the overworld.
	CMP #$C0
	BNE +
	LDA #$40			;\ Use the third row of 16x16 tiles if track $C0 is playing (for One Last Thing).
	STA $03				;/
	BRA ++
+
	CMP #$C1
	BNE ++
	LDA #$20			;\ Use the second row of 16x16 tiles if track $C1 is playing (for Cosmic Heaven).
	STA $03				;/
++

	; Load the 24-bit address of the logo tilemap.
	LDA.b #logo      : STA $00
	LDA.b #logo>>8   : STA $01
	LDA.b #logo>>16  : STA $02

	; Use the MaxTile system to request OAM slots. Needs SA-1 v1.40.
	LDY.b #$00+(!NumTiles)	;> Input parameter for call to MaxTile.
	REP #$30				;> (As the index registers were 8-bit, this fills their high bytes with zeroes)
	LDA.w #$0000			;> Maximum priority. Input parameter for call to MaxTile.
	JSL $0084B0				;\ Request MaxTile slots (does not modify scratch ram at the time of writing).
							;| Returns 16-bit pointer to the OAM general buffer in $3100.
							;/ Returns 16-bit pointer to the OAM attribute buffer in $3102.
	BCC .return				;\ Carry clear: Failed to get OAM slots, abort.
							;/ ...should never happen, since this will be executed before sprites, but...
	JSR Draw
.return
	SEP #$30

	LDA #$18			;\ Original code.
	STA $00				;/
	RTL

;=================================
; Draw sprite tiles (uses SP2)
;=================================

Draw:
	PHB
	PHK
	PLB

	; OAM table
	LDX $3100						;> Main index (16-bit pointer to the OAM general buffer)
	LDY.w #$0000+((!NumTiles-1)*2)	;> Loop index
-
	LDA TileYX,y					;\ Load base X and Y coordinates
	STA $400000,x					;/

	LDA [$00],y						;\ Get the appropriate tile.
	CLC								;|
	ADC #!TileProp					;/
	CLC								;\ Add the row offset for the logo.
	ADC $03							;/
	STA $400002,x					;> Store to MaxTile

	INX #4							;\ Move to next slot and loop
	DEY #2							;|
	BPL -							;/

	; OAM extra bits
	LDX $3102						;> Bit table index (16-bit pointer to the OAM attribute buffer)
	LDY.w #$0000+(!NumTiles)/2-1	;> Loop index (assumes even number of tiles)
	LDA.w #$0202					;> Big (16x16) for both tiles
	;LDA.w #$0000					;> Small (8x8) for both tiles
-
	STA $400000,x					;> Store to both

	INX #2							;\ Loop to set the remaining OAM extra bits.
	DEY								;|
	BPL -							;/

	PLB
	RTS

;=================================
; Dynamically generate tile coords
;=================================

TileYX:
!counter #= !NumTiles
!tempcoordinate #= !TileOrigin
while !counter > 0
	dw !tempcoordinate
	!tempcoordinate #= !tempcoordinate+$0010
	!counter #= !counter-1
endif

;=================================
; Map name data
;=================================

logo:
	dw $0080,$0082,$0084,$0086,$0088,$008A,$008C,$008E
