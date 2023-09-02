;gamemode 14 (level).
main:
	;You can have codes (including JSL to library codes, just like the one below here) between the main label (above) and the code below here, if you want
	;third-party stuff here.
	JSL retry_in_level_main
	JSL ScreenScrollingPipes_SSPMaincode
	;JSR setup_counters

	;...or codes here before the RTL.
;	LDA #$7F		;\ Make the player invincible.
;	STA $1497|!addr		;/ (Testing purposes.)

	; Handle Iris palette with ExAnimation custom trigger.
	LDA $0DB3|!addr 
	CMP #$00
	BNE .Iris
	LDA #$00
	STA $7FC0FC
	JML .Return
.Iris
	LDA #$01  ;Bit value
	STA $7FC0FC
.Return
	RTL

nmi:
	JSL retry_nmi_level
	;JSR custom_bar
	RTL

setup_counters:
	; Setup ExAnimation lives counter.
	LDA $0DBE|!addr		;\ Load current player's lives.
	INC A			;/ SMW indexes from zero, so need to add one here to account for that.
	JSL $00974C		;> HexToDec function (returns ones digit in A and tens digit in X)
	STA $7FC072		;> Store ones digit in Manual 2 ExAnimation Trigger (uses global slot 05 and destination tile 447)
	TXA
	STA $7FC071		;> Store tens digit in Manual 1 ExAnimation Trigger (uses global slot 04 and destination tile 446)

	; Setup ExAnimation timer.
	LDA $0F31|!addr		;> Load hundreds digit of timer
	STA $7FC075		;> Store hundreds digit in Manual 5 ExAnimation Trigger (uses global slot 08 and destination tile 423)
	LDA $0F32|!addr		;> Load tens digit of timer
	STA $7FC074		;> Store tens digit in Manual 4 ExAnimation Trigger (uses global slot 07 and destination tile 432)
	LDA $0F33|!addr		;> Load ones digit of timer
	STA $7FC073		;> Store ones digit in Manual 3 ExAnimation Trigger (uses global slot 06 and destination tile 433)

	RTS

custom_bar:
	LDY #$B0		;> Offset for OAM table. Start at an arbitrarily high slot (careful it doesn't cause any conflicts).
	LDA #$10		;\ X offset for the entire status bar.
	STA $00			;/
	LDA #$10		;\ Y offset for the entire status bar.
	STA $01			;/

	LDA #$00		;\ Offset for prop_word table (starts at 0)
	TAX			;/
	REP #$30		;> Change A, X, and Y to 16-bit mode
	LDA tiles,x		;\ Read the first line from the table
	TAX			;/ (i.e., the minimum number of tiles to draw)
	SEP #$20		;> Change A to 8-bit mode, keep X and Y in 16-bit mode

	LDA $0000,x		;\ Load the minimum number of tiles to draw
	CLC			;|
	ADC $1420|!addr		;/ Then add the amount of dragon coins collected in the level so far
	STA $0F			;> $0F contains the total number of tiles to draw
	INX			;> Start reading the table in chunks of 4 bytes (for each tile)
-
	; Write the tile coordinates to OAM.
	LDA $0000,x		;\
	CLC			;| Load X coordinate for the current tile
	ADC $00			;| Add the X offset
	STA $0200|!addr,y	;/
	LDA $0001,x		;\
	CLC			;| Load Y coordinate for the current tile
	ADC $01			;| Add the Y offset
	STA $0201|!addr,y	;/

	; Write the tile number/property to OAM.
	LDA $0DB3|!addr		;> Check if the player is Demo or Iris
	BEQ ++			;> Branch if Demo. Otherwise, the player is Iris.
	LDA #$01		;\ Store Iris' tile in Manual 1 ExAnimation Trigger (uses global slot 03 and destination tile 444)
	STA $7FC070		;/
	BRA +
++
	LDA #$00		;\ Store Demo's tile in Manual 1 ExAnimation Trigger (uses global slot 03 and destination tile 444)
	STA $7FC070		;/
+
	LDA $0002,x		;\ Write the tile number to OAM.
	STA $0202|!addr,y	;/
	LDA #$30		;\ Write the tile property to OAM. (YXPP CCCT = 0011 0000)
	STA $0203|!addr,y	;/
	PHY
	REP #$20
	TYA
	LSR #2
	TAY
	SEP #$20
	LDA $0003,x		;\ Write the OAM extra bits
	STA $0420|!addr,y	;/ Tile size: $00 = 8x8, $02 = 16x16
	PLY
	INY #4			;> Next OAM slot
	INX #4			;> Next line in the tile table
	DEC $0F			;> Update value for number of tiles remaining to be drawn
	BNE -			;> Branch if there are still tiles to draw
	SEP #$10		;> Change X and Y to 8-bit mode
	RTS

tiles:
	dw tile_byte

tile_byte:
	; Minimum number of tiles to be drawn
	db $10
	
	; Tiles for lives counter
	db $00,$00,$44,$02	;> Demo/Iris head
	db $14,$04,$4B,$00	;> "x"
	db $1C,$04,$46,$00	;> Tens digit
	db $24,$04,$47,$00	;> Ones digit

	; Tiles for timer
	db $84,$00,$7E,$00	;> Clock
	db $8C,$00,$0A,$00	;> Hundreds digit
	db $94,$00,$0C,$00	;> Tens digit
	db $9C,$00,$0D,$00	;> Ones digit

	; Tiles for coin counter
	db $84,$08,$29,$00	;> Coin
	db $8C,$08,$4B,$00	;> "x"
	db $94,$08,$38,$00	;> Tens digit
	db $9C,$08,$39,$00	;> Ones digit

	; Tiles for bonus star counter
	db $34,$08,$EF,$00	;> Star
	db $3C,$08,$4B,$00	;> "x"
	db $44,$08,$1A,$00	;> Tens digit
	db $4C,$08,$1B,$00	;> Ones digit

	; Tiles for dragon coins
	db $2C,$00,$29,$00
	db $34,$00,$29,$00
	db $3C,$00,$29,$00
	db $44,$00,$29,$00
	db $4C,$00,$29,$00
